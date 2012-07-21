require 'rubygems'
require 'puppet'
require 'yaml'
require 'json'
require 'httparty'
require 'time'
require 'socket'


Puppet::Reports.register_report(:irccat) do

  desc <<-DESC
  Send notification of failed reports to an irccat server.
  DESC

  def irccatter( string , server , port )
    begin
      socket ||= TCPSocket.new( server , port )
      socket.send( string , 0 )
      socket.close
    rescue => e
      Puppet.debug "Failed to IRCCat because of #{e}"
    end
  end

  def find_node( node_name , dashboard )

    url = nil
    JSON.parse( HTTParty.get( "#{dashboard}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/nodes/#{node['id']}".gsub( /[^:]\/\/+/ , '/' ) if node['name'] == node_name
    end

    return false
  end


  def find_report( node_name , dashboard )

    JSON.parse( HTTParty.get( "#{dashboard}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/reports/#{node['last_apply_report_id']}" if node['name'] == node_name and node['status'] == 'failed'
    end

    # If not, just return the node list.
    return "#{dashboard}/nodes/#{node_name}"
  end


  def getconfig
    config = {}
    configfile = File.join([File.dirname(Puppet.settings[:config]), "irccat.yaml"])
    raise(Puppet::ParseError, "irccat report config file #{configfile} not readable") unless File.exist?(configfile)

    config = YAML.load_file(configfile)

    # Remove any trailing slashes on the URL, so we can join it with
    # '/path/' later on.
    config[:dashboard].chomp!( '/' )

    # there are less ugly ways to do defaults.
    config[:irccatport] = 12345 unless config[:irccatport]

    return config
  end

  def process

    # get the config every time, so we don't have to restart it to add
    # users/ignored hosts.
    c = self.getconfig


    # If you want to debug this...
    Puppet.warning  "irccat-debug: There's a status for #{self.host} to irccat in env \"#{self.environment}\" which is status #{self.status}"

    # We can get the SHA out of our report (we use the git SHA as the
    # version, thanks Cody!)
    if c[:githuburl] and not c[:githuburl].nil?
      commit_string = ''
      sha = self.configuration_version
      if sha =~ /^[0-9a-zA-Z]+$/
        commit_string = " see #{c[:githuburl]} for #{sha}"
        Puppet.debug "irccat-debug: we has commit string #{sha}"
      else
        Puppet.warning "irccat-debug: no usable configuration version string of '#{sha}' for #{self.host}"
      end
    end

    # Don't alert on weekends.
    day = Time.now.wday
    if day == 0 or day == 6 # Sat or Sun
      return
    end


    # If it's an ignored host, don't bother beyond here.
    return if c[:ignore_hosts].include? self.host


    # If we ctrl-c'ed then don't bother alerting!!
    begin
      if self.logs.last.message == 'Caught INT; calling stop'
        Puppet.warning "irccat-debug: Am not telling you about #{self.host} as you CTRL-Ced it."
        return
      end
    rescue NameError => e
      # I am here in case it doesn't exist.
    end

    # Go through all the log messages and check their message for an
    # environment. Sketch..
    # "Could not retrieve catalog from remote server: Error 400 on SERVER:
    # validate_re(): wrong number of arguments (3; must be 2) at
    # /etc/puppet/environments/flowers/sherwood/apacheds/manifests/config.pp:14
    # on node buttons.puppetlabs.net"
    # For example.
    self.logs.each do |log|
      if log.message =~ /Could not retrieve catalog from remote server: Error 400 on SERVER: .* \/etc\/puppet\/environments\/(\w+)\//
        env = $1
        if env != 'production'
          Puppet.warning "irccat-debug: Ignoring #{self.host} as it's technically in #{env} environment."
          return
        end
      end
    end


    if self.status == 'failed'

      dashboard_report_url = find_report( self.host , c[:dashboard] )

      # Thanks to https://projects.puppetlabs.com/issues/10064 we now have an
      # environment to check against.
      if self.environment.nil? or self.environment == 'production'

        body = "Puppet #{self.status} for #{self.host} #{dashboard_report_url}#{commit_string}"

        irccatter( body , c[:irccathost] , c[:irccatport] )

      end
    end
  end

end
