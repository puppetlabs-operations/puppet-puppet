#! /usr/bin/env ruby
##
# So could probably make this more modular. But that's just the fact it was a 5
# line shell script, and now it's a Ruby script with a class in it. Get over it.
#
# This purely checks out our github repo and puts all the branches in their own
# dir. Inspired by/copied from
# http://hunnur.com/blog/2010/10/dynamic-git-branch-puppet-environments/
#
# Hardcode city. Suck it up.
#

require 'rubygems'
require 'statsd'
require 'fileutils'
require 'optparse'
require 'socket'

# the https://github.com/bvandenbos/statsd-client version
Statsd.host = 'statsd.dc1.puppetlabs.net'
Statsd.port = 8125

shorthostname = Socket.gethostname.split('.').first
statname = "puppetgitdeploy.#{shorthostname}"

github_repo_urls = { :default => 'git@github.com:puppetlabs/puppetlabs-modules.git' }

# Identifer for individual repos.
$NSIDENT = 'nonPL'

# $modulepath=`puppet master --configprint modulepath`
env_base_dir  = '/etc/puppet/environments'

$debug      = false
$submodules = true
$librarian  = true
$gitnoise   = "--quiet"
$branch     = nil

# By enabling this option, it deletes the Puppetfile.lock in librarian
# mode. This has the effect of always pulling down the version specified
# in the Puppetfile, and not the version you pulled down in the now
# missing Puppetfile.lock. The upshot of this is that you can work on a
# repo that you Puppetfile with a ref => 'branchname' and it will track
# that branch name, rather than the commit in that branchname at time of
# writing the Puppetfile.
#
# The downside of this is it probably takes longer, and you no longer have
# a fixed version a la librarian, you run whatever is at that :ref at that
# time.
#
# Without it, you're back to double commiting when you develop (the change
# to the module and the updated Puppetfile.lock after running
# 'librarian-puppet update'.
$librarian_temerarious  = true
$librarian_noise = ''

def parse(args)

  opt_parser = OptionParser.new do |opts|
    opts.banner = "#{$0}: [options] [environment]"

    opts.on('-p', '--parallel', "Run updates in parallel") do
      $parallel = "GO REALLY FAST"
    end

    opts.on('-b', '--branch=nom', "Just update named branch") do |val|
      $branch = val
    end

    opts.on('-d', '--debug=val', "Include debug output",
                                 "Values: [exec, librarian, git, all]") do |val|
      $debug = true

      case val
      when 'exec'
        $execnoise = 'this is noisy.'
      when 'git'
        $gitnoise = ''
      when 'librarian'
        $librarian_noise = '--verbose'
      when 'all'
        $gitnoise        = ''
        $librarian_noise = '--verbose'
        $execnoise       = 'this is noisy.'
      else
        $stderr.puts "Given unrecognized debug type of '#{val}', ignoring it"
      end
    end

    opts.on('--[no-]librarian', "Update librarian") do |bool|
      $librarian = bool
    end

    opts.on('--[no-]submodules', "Update submodules") do |bool|
      $submodules = bool
    end

    opts.on('-h', '--help', "Display this help") do
      puts opts
      exit
    end
  end

  opt_parser.parse!(args)
rescue => e
  $stderr.puts e
  $stderr.puts opt_parser
  exit 1
end

def pp_and_system(dome)
  puts "* Execute: \"#{dome}\"" if $execnoise
  system dome
end

def dputs(text)
  puts text if $debug
end

#
# @return [Float] The duration of the operation in seconds
def benchmark(&block)
  initial = Time.now.to_f
  yield
  completion = Time.now.to_f

  (completion - initial).round
end

def lock(path, &block)

  lockfile = File.new(path, 'w')
  locked   = false

  if lockfile.flock(File::LOCK_EX | File::LOCK_NB)
    locked = true
    yield
  else
    raise "Unable to lock #{path}"
  end
ensure
  if locked
    # unlink before unlocking to prevent race conditions
    File.unlink(path)
    lockfile.flock(File::LOCK_UN)
  end
  lockfile.close unless lockfile.closed?
end

class GitRepo

  attr_accessor :repo, :branches, :branchcount

  def initialize(base_dir, git_name, git_repo_url)

    @git_repo_url = git_repo_url
    @namespace    = git_name == :default ?  '' : "#{$NSIDENT}#{git_name}" # :default doesn't have a namespace, but everything else should.
    @env_base_dir = base_dir
    @mirrordir = "#{@env_base_dir}/.github_pl_#{@namespace}modules_repo"

    check_env_dir
    mirror_repo

    @branches = self.get_branches
    @branchcount = @branches.size
  end

  # check the dir exists, try and make it if not. Bail if we have to.
  private
  def check_env_dir
    unless File.directory? @env_base_dir
      begin
        dputs "Trying to mkdir -p to #{@env_base_dir}"
        FileUtils.mkdir_p @env_base_dir
      rescue
        raise "Can't make environments base dir of #{@env_base_dir}."
      end
    end
  end
  public

  # Add the check for $branch here, because that way it works (stupidly,
  # some would say) even if you specify sequential or parallel.
  def get_branches
    dputs "Fetching current list of branches from #{@mirrordir}"
    Dir.chdir @mirrordir do

      branches_wot_we_have = []

      `git branch -a`.split("\n").each do |branch|
        branch = branch.split(/ +/)[1]
        next if branch =~ /remotes\/origin\/(HEAD|master)/
        next if branch =~ /\// # Zach safe code.

        branches_wot_we_have << branch
      end

      # Is this the right thing to do here? If we set a branch, and it's
      # not in there, is falling back to doing all of them correct?
      if ! $branch.nil? and branches_wot_we_have.include? $branch
        return $branch
      end

      dputs "Branches to instantiate:"
      branches_wot_we_have.each do |br|
        dputs "  - #{br}"
      end

      dputs "(#{branches_wot_we_have.size} total)"
      branches_wot_we_have
    end
  end

  def populate_branchi_concurrent
    pidlist = []
    @branches.each do |branchname|
      pid = fork
      if pid.nil?
        br = GitBranch.new(branchname, @env_base_dir, @mirrordir)
        br.make!
        Process.exit # Since this is a child process, exit after doing the work.
      else
        pidlist << pid
      end
    end

    pidlist.each { |pid| Process.waitpid pid, 0 }
  end

  def populate_branchi_sequential
    @branches.each do |branchname|
      br = GitBranch.new(branchname, @env_base_dir, @mirrordir)
      br.make!
    end
  end

  # If parallelism is requested, then fork a child for each branch and let them
  # all run at once. Otherwise, do each one sequentially.
  def populate_branchi
    if $parallel
      populate_branchi_concurrent
    else
      populate_branchi_sequential
    end
  end


  def fetch_master
    # just assume it's checked out, for now.
    Dir.chdir @mirrordir do
      pp_and_system("git fetch #{$gitnoise} --all --prune")
    end
  end

  # Clone the main modules repository and cache it locally so that subsequent
  # clones will be hard linked when possible.
  def mirror_repo
    if File.directory? @mirrordir
      dputs "Updating mirror of #{@git_repo_url} at #{@mirrordir}"
      fetch_master
    else
      dputs "Mirroring #{@git_repo_url} to #{@mirrordir}"
      pp_and_system("git clone #{$gitnoise} --mirror #{@git_repo_url} #{@mirrordir}")
    end
  end

  # Check for any environments/branches that exist in the directory but do not
  # have an according git branch
  def delete_extraneous_branches

    unless $branch.nil?
      dputs "Not deleting branches, as I'm in single branch mode."
      return true
    end

    Dir.chdir @env_base_dir do
      Dir.glob('*') do |dir|
        next if dir == "#{@namespace}production" # Hardcode DON'T RM PROD!
                                                 # :default will namespace to ''
        next unless File.directory? dir
        next if @branches.include? dir

        # Remove things, but base it on namespaces.
        if @namespace.empty?
          next if dir =~ /^#{$NSIDENT}/
        else
          next if dir !~ /^#{@namespace}/

          # It is our name space, but which branches?
          next if @branches.collect { |b| @namespace + b }.include? dir
        end

        # if we're here, it's not prod, it is a directory and it isn't a branch
        # we have.
        cmd = %Q!rm -rf "#{@env_base_dir}/#{dir}"!
        pp_and_system cmd
      end
    end
  end
end

class GitBranch

  #
  # @param [String] branchname The name of the git branch
  # @param [String] The base directory to instantiate the branch
  # @param [String] The path of the git source repository
  def initialize(branchname, basedir, source_repo)
    @branchname  = branchname
    @basedir     = basedir
    @source_repo = source_repo
    @directory   = (branchname == 'master' ? 'production' : branchname)
  end

  def full_path
    @full_path ||= File.join(@basedir, @directory)
  end

  def make!
    Dir.chdir @basedir do
      if File.directory? full_path
        update_existing_branch
      else
        create_new_branch
      end

      update_branch_members
    end
  end

  def update_existing_branch
    dputs "Fetching existing branch #{full_path}"
    Dir.chdir full_path do
      pp_and_system "git fetch #{$gitnoise} --all && git reset #{$gitnoise} --hard origin/#{@branchname}"
    end
  end

  def create_new_branch
    dputs "Cloning new branch #{full_path}"
    Dir.chdir @basedir do
      pp_and_system "git clone #{$gitnoise} -b #{@branchname} #{@source_repo} #{full_path}"
    end
  end

  # Update any sort of nested repository structures
  def update_branch_members
    Dir.chdir full_path do
      if $submodules
        pp_and_system "git submodule #{$gitnoise} update --init | grep -vE 'Cloning into |^From |->'" unless %x{ git submodule status }.empty?
      end

      if $librarian && File.exist?('Puppetfile')
        # Display updating branch in proctitle
        procname = $0
        $0 = "#{File.basename(__FILE__)}: Updating librarian-puppet in branch #{@basedir}"

        # sketchy librarian mode?
        File.delete('Puppetfile.lock') if $librarian_temerarious && File.exist?('Puppetfile.lock')
        pp_and_system "/var/lib/gems/1.8/bin/librarian-puppet install #{$librarian_noise}"

        $0 = procname
      end
    end
  end
end

def run
  parse(ARGV)

  # Change the environment so that all subprocesses get a reasonable LANG
  ENV['LANG'] = 'C'

  startdir = Dir.getwd

  github_repo_urls.each_pair do |username, repo|

    dputs "Generating branches from user #{username.to_s}, repository \"#{repo}\""

    # In case that any of the following code changes the directory but
    # doesn't change back, we ensure we're in the right directory before
    # continuing.
    Dir.chdir startdir

    g = GitRepo.new(env_base_dir, username, repo)

    # Do all the wee bonnie branches other than main. This will clone them from the
    # repo we just checked out, so it's a local only operation.
    g.populate_branchi
    g.delete_extraneous_branches
  end

  # odyi | barn: "Might not be all just thin.  There is a bug with the
  # config version thing.  Only way to make it go away is to touch
  # site.pp of the environment you just updated."
  system('/usr/bin/find /etc/puppet/ -maxdepth 3 -mindepth 3 -type f -name site.pp | xargs touch')
end

if __FILE__ == $0

  begin
    lock('/var/lock/puppet_deploy.lock') do
      timing = benchmark do
        run
      end

      mode = $parallel ? 'parallel' : 'sequential'
      puts "Update duration: #{timing} seconds. (mode: #{mode})"

      Statsd.timing(statname, timing)
    end
  rescue => e
    $stderr.puts "Error while updating: #{e}"
  end
end
