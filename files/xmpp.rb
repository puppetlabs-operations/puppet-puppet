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
    JSON.parse( HTTParty.get( "#{dashboard}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/nodes/#{node['id']}".gsub( /[^:]\/\/+/ , '/' ) if node['name'] == node_name
    end

    return false
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

    day = Time.now.wday
    if day == 0 or day == 6 # Sat or Sun
      return
    end

    # Am bored of this now...
    return if self.host == 'urd.puppetlabs.lan'

    # If we ctrl-c'ed then don't bother alerting!!
    begin
      if self.logs.last.message == 'Caught INT; calling stop'
        Puppet.warning "xmpp-debug: Am not telling you about #{self.host} as you CTRL-Ced it."
        return
      end
    rescue NameError => e
      # I am here in case it doesn't exist.
    end

    if self.status == 'failed'

      # get the config every time, so we don't have to restart it to add
      # users.
      c = self.getconfig

      jid = JID::new(c[:xmpp_jid])
      cl = Client::new(jid)
      cl.connect
      cl.auth(c[:xmpp_password])

      # host = find_node( self.host , DASHBOARD_URL )
      host = "#{c[:dashboard]}/nodes/#{self.host}"

      # We can get the SHA out of our report (we use the git SHA as the
      # version, thanks Cody!)
      commit_string = ''
      sha = self.configuration_version
      if sha and sha =~ /^[0-9a-zA-Z]$/
        commit_string = " see http://git.io/plmc for #{sha}"
        Puppet.debug "xmpp-debug: we has commit string #{sha}"
      else
        Puppet.debug "xmpp-debug: no commit string of '#{sha}' for #{self.host}"
      end

      # Thanks to https://projects.puppetlabs.com/issues/10064 we now have an
      # environment to check against.
      #
      # Need the nil? for things that break before sending their env.
      if self.environment.nil? or self.environment == 'production'

        body = "Puppet run #{self.status} for #{host}#{commit_string}"

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
