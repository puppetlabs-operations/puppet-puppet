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

require 'pp'
require 'fileutils'
require 'optparse'
require 'socket'


# the https://github.com/bvandenbos/statsd-client version
require 'rubygems'
require 'statsd'
Statsd.host = 'statsd.dc1.puppetlabs.net'
Statsd.port = 8125

shorthostname = Socket.gethostname.split('.').first
statname = "puppetgitdeploy.#{shorthostname}"

github_repo_urls = { :default => 'git@github.com:puppetlabs/puppetlabs-modules.git',
                     # :adrient => 'git@github.com:adrienthebo/puppetlabs-modules.git',
                     #:zach    => 'git@github.com:xaque208/puppetlabs-modules.git'
}

# Identifer for individual repos.
$NSIDENT = 'nonPL'

# $modulepath=`puppet master --configprint modulepath`
env_base_dir  = '/etc/puppet/environments'

$debug      = false
$submodules = true
$librarian  = true
$gitnoise   = "--quiet"

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

    opts.on('-d', '--debug=val', "Include debug output") do |val|
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
      end
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
  pp dome if $execnoise
  system dome
end

def dputs(text)
  puts text if $debug
end

class GitRepo

  attr_accessor :repo, :branches, :branchcount

  def initialize(base_dir, git_name, git_repo_url)

    @git_repo_url = git_repo_url
    @namespace    = git_name == :default ?  '' : "#{$NSIDENT}#{git_name}" # :default doesn't have a namespace, but everything else should.

    check_env_dir base_dir

    @env_base_dir = base_dir
    @mirrordir = "#{@env_base_dir}/.github_pl_#{@namespace}modules_repo"
    # We need to mirror the repo before we can get the list of branches!
    self.mirror_repo

    @branches = self.get_branches
    @branchcount = @branches.size
  end

  # check the dir exists, try and make it if not. Bail if we have to.
  private
  def check_env_dir(base_dir)
    unless File.directory? base_dir
      begin
        dputs "Trying to mkdir -p to #{base_dir}"
        FileUtils.mkdir_p base_dir
      rescue
        raise "Can't make environments base dir of #{base_dir}."
      end
    end
  end
  public

  def get_branches
    dputs "CDing to #{@mirrordir} from #{Dir.getwd}"
    Dir.chdir @mirrordir do

      branches_wot_we_have = []

      `git branch -a`.split("\n").each do |branch|
        branch = branch.split(/ +/)[1]
        next if branch == "master"
        next if branch =~ /remotes\/origin\/(HEAD|master)/
        next if branch =~ /\// # Zach safe code.

        branches_wot_we_have << branch
      end

      branches_wot_we_have
    end
  end

  def populate_branchi_concurrent
    pidlist = []
    @branches.each do |branch|
      pid = fork
      if pid.nil?
        make_subbranch(branch)
        Process.exit # Since this is a child process, exit after doing the work.
      else
        pidlist << pid
      end
    end

    pidlist.each do |pid|
      Process.waitpid pid, 0
      # Fancy output for monitoring progress.
      # XXX this will generate noise when used as a library.
      $stdout.print '.'
      $stdout.flush
    end
    puts # Part of fancy output for parallel operation.
  end

  def populate_branchi_sequential
    @branches.each do |b|
      self.make_subbranch b
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

  def update_existing_branch(directory, branchname)
    dputs "doing a pull on an existing branch"
    Dir.chdir directory do
      pp_and_system "git fetch #{$gitnoise} --all && git reset #{$gitnoise} --hard origin/#{branchname}" # origin #{branch_to_make}"
      if $submodules
        pp_and_system "git submodule #{$gitnoise} update --init | grep -vE 'Cloning into |^From |->'" unless %x{ git submodule status }.empty?
      end

      if $librarian && File.exist?('Puppetfile')
        # sketchy librarian mode?
        File.delete('Puppetfile.lock') if $librarian_temerarious && File.exist?('Puppetfile.lock')

        pp_and_system "/var/lib/gems/1.8/bin/librarian-puppet install #{$librarian_noise}"
      end

    end
  end

  def create_new_branch(directory, branchname)
    dputs "doing a clone on a new branch"
    Dir.chdir @env_base_dir do
      pp_and_system "git clone #{$gitnoise} -b #{branchname} #{@mirrordir} #{directory}"
      pp_and_system "cd #{checkout_as} && git submodule #{$gitnoise} update --init | grep -vE 'Cloning into |^From |->'" unless %x{cd #{directory} && git submodule status}.empty?

      if $librarian && File.exist?("#{directory}/Puppetfile")
        # sketchy librarian mode?
        File.delete("#{checkout_as}/Puppetfile.lock") \
          if $librarian_temerarious && File.exist?('#{checkout_as}/Puppetfile.lock')

        pp_and_system "cd #{directory} && /var/lib/gems/1.8/bin/librarian-puppet install #{$librarian_noise}"
      end
    end
  end

  # Generate a environment from a git branch
  #
  # @param [String] branch_to_make The name of the git branch
  # @param [String] make_as The name of the directory to create the branch
  def make_subbranch(branch_to_make, make_as=nil)
    dputs "Making ol' #{branch_to_make}"

    Dir.chdir @env_base_dir do
      checkout_directory = branch_to_make.split('/').last

      # If a specific branch name has been supplied, then use that. Else, fall
      # back to the name of the branch and use that. if a namespace is supplied,
      # then prepend that.
      checkout_as = @namespace + (make_as || checkout_directory)

      branch_dir = "#{@env_base_dir}/#{checkout_as}"

      if File.directory? branch_dir
        update_existing_branch(branch_dir, branch_to_make)
      else
        create_new_branch(branch_dir, branch_to_make)
      end
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
      fetch_master
    else
      dputs "Making clone of remote repo locally to #{@mirrordir}"
      pp_and_system("git clone #{$gitnoise} --mirror #{@git_repo_url} #{@mirrordir}")
    end
  end

  # Check for any environments/branches that exist in the directory but do not
  # have an according git branch
  def delete_extraneous_branches
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

if __FILE__ == $0

  parse(ARGV)

  # Change the environment so that all subprocesses get a reasonable LANG
  ENV['LANG'] = 'C'

  startdir = Dir.getwd
  Statsd.timing(statname) do

    github_repo_urls.each_pair do |username, repo|

      dputs "Working on #{username}'s repo from #{repo}"

      # In case that any of the following code changes the directory but
      # doesn't change back, we ensure we're in the right directory before
      # continuing.
      Dir.chdir startdir

      g = GitRepo.new(env_base_dir, username, repo)

      # Do all the wee bonnie branches other than main. This will clone them from the
      # repo we just checked out, so it's a local only operation.
      g.populate_branchi

      # By default it ignores master, this throws it in to production.
      g.make_subbranch("master", "production")

      # Finally, tidy up other branches/envs
      g.delete_extraneous_branches

    end
  end

  # odyi | barn: "Might not be all just thin.  There is a bug with the
  # config version thing.  Only way to make it go away is to touch
  # site.pp of the environment you just updated."
  system('/usr/bin/find /etc/puppet/ -maxdepth 3 -mindepth 3 -type f -name site.pp | xargs touch')
end
