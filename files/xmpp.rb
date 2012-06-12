require 'puppet'
require 'yaml'
require 'json'
require 'httparty'
require 'time'
require 'socket'

begin
  require 'xmpp4r/client'
  include Jabber
rescue LoadError => e
  Puppet.info "You need the `xmpp4r` gem to use the XMPP report"
end

# Dirty class with no timeotus, or config, or pretty much anything really.
class IRCKitten
  def self.message( string )
    begin
      socket ||= TCPSocket.new('jotunn.puppetlabs.lan', 12345)
      socket.send( string , 0 )
      socket.close
    rescue => e
      Puppet.debug "Failed to IRCCat because of #{e}"
    end
  end
end



Puppet::Reports.register_report(:xmpp) do

  desc <<-DESC
  Send notification of failed reports to an XMPP user.
  DESC

  def find_node( node_name , dashboard )

    url = nil
    JSON.parse( HTTParty.get( "#{dashboard.chomp('/')}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/nodes/#{node['id']}".gsub( /[^:]\/\/+/ , '/' ) if node['name'] == node_name
    end

    return false
  end


  def find_report( node_name , dashboard )

    JSON.parse( HTTParty.get( "#{dashboard.chomp('/')}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/reports/#{node['last_apply_report_id']}" if node['name'] == node_name and node['status'] == 'failed'
    end

    # If not, just return the node list.
    return "#{dashboard.chomp('/')}/nodes/#{node_name}"
  end


  def getconfig
    configs = {}
    configfile = File.join([File.dirname(Puppet.settings[:config]), "xmpp.yaml"])
    raise(Puppet::ParseError, "XMPP report config file #{configfile} not readable") unless File.exist?(configfile)

    config = YAML.load_file(configfile)

    return config

    # not used any more.
    # XMPP_JID = config[:xmpp_jid]
    # XMPP_PASSWORD = config[:xmpp_password]
    # XMPP_TARGET = config[:xmpp_target]
    # DASHBOARD_URL = config[:dashboard].chomp('/') # remove trailing slash.
  end

  def process

    # If you want to debug this...
    Puppet.warning  "xmpp-debug: There's a status for #{self.host} to XMPP in env \"#{self.environment}\" which is status #{self.status}"

    # We can get the SHA out of our report (we use the git SHA as the
    # version, thanks Cody!)
    commit_string = ''
    sha = self.configuration_version
    if sha =~ /^[0-9a-zA-Z]+$/
      commit_string = " see http://git.io/plmc for #{sha}"
      Puppet.debug "xmpp-debug: we has commit string #{sha}"
    else
      Puppet.warning "xmpp-debug: no usable configuration version string of '#{sha}' for #{self.host}"
    end

    # Don't alert on weekends.
    day = Time.now.wday
    if day == 0 or day == 6 # Sat or Sun
      return
    end

    # If we ctrl-c'ed then don't bother alerting!!
    begin
      if self.logs.last.message == 'Caught INT; calling stop'
        Puppet.warning "xmpp-debug: Am not telling you about #{self.host} as you CTRL-Ced it."
        return
      end
    rescue NameError => e
      # I am here in case it doesn't exist.
    end

    # Go through all the log messages and check their message for an
    # environment. Sketch..
    # "Could not retrieve catalog from remote server: Error 400 on SERVER:
    # validate_re(): wrong number of arguments (3; must be 2) at
    # /etc/puppet/environments/doing_ldap_not_badly/sherwood/apacheds/manifests/config.pp:14
    # on node yellow.dc1.puppetlabs.net"
    # For example.
    self.logs.each do |log|
      if log.message =~ /Could not retrieve catalog from remote server: Error 400 on SERVER: .* \/etc\/puppet\/environments\/(\w+)\//
        env = $1
        if env != 'production'
          Puppet.warning "xmpp-debug: Ignoring #{self.host} as it's technically in #{env} environment."
          return
        end
      end
    end


    if self.status == 'failed'

      # get the config every time, so we don't have to restart it to add
      # users/ignored hosts.
      c = self.getconfig


      # If it's an ignored host, don't bother beyond here.
      return if c[:ignore_hosts].include? self.host


      # Now set us up some Jabber
      jid = JID::new(c[:xmpp_jid])
      cl = Client::new(jid)
      cl.connect
      cl.auth(c[:xmpp_password])

      # host = find_node( self.host , DASHBOARD_URL )
      # host = "#{c[:dashboard].chomp('/')}/nodes/#{self.host}"
      dashboard_report_url = find_report( self.host , c[:dashboard] )

      # Thanks to https://projects.puppetlabs.com/issues/10064 we now have an
      # environment to check against.
      #
      # Need the nil? for things that break before sending their env.
      if self.environment.nil? or self.environment == 'production'

        body = "Puppet #{self.status} for #{self.host} #{dashboard_report_url}#{commit_string}"

        c[:xmpp_target].split(',').each do |target| 
          Puppet.debug "Sending status for #{self.host} to XMMP user #{target}"
          m = Message::new(target, body).set_type(:normal).set_id('1').set_subject("Puppet run failed!")
          cl.send m

        end

        # Yeah, don't do IRC in the loop, as then you get N messages.
        IRCKitten::message( body )

      end
    end
  end

end
