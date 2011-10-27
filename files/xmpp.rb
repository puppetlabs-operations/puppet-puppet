require 'puppet'
require 'yaml'
require 'json'
require 'httparty'                                                                                                     

begin
  require 'xmpp4r/client'
  include Jabber
rescue LoadError => e
  Puppet.info "You need the `xmpp4r` gem to use the XMPP report"
end



Puppet::Reports.register_report(:xmpp) do

  def find_node( node_name , dashboard )

    url = nil
    JSON.parse( HTTParty.get( "#{dashboard}/nodes.json" ).response.body ).each do |node|
      return "#{dashboard}/nodes/#{node['id']}".gsub( /[^:]\/\/+/ , '/' ) if node['name'] == node_name
    end

    return false
  end

  configfile = File.join([File.dirname(Puppet.settings[:config]), "xmpp.yaml"])
  raise(Puppet::ParseError, "XMPP report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  XMPP_JID = config[:xmpp_jid]
  XMPP_PASSWORD = config[:xmpp_password]
  XMPP_TARGET = config[:xmpp_target]
  DASHBOARD_URL = config[:dashboard].chomp('/') # remove trailing slash.

  desc <<-DESC
  Send notification of failed reports to an XMPP user.
  DESC

  def process
    if self.status == 'failed'
      jid = JID::new(XMPP_JID)
      cl = Client::new(jid)
      cl.connect
      cl.auth(XMPP_PASSWORD)

      host = find_node( self.host , DASHBOARD_URL )
      host ||= "#{DASHBOARD_URL}/nodes?q=#{self.host}"

      env = "/#{self.environment}" if defined? self.environment 

      body = "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}, at #{host}"
      XMPP_TARGET.split(',').each do |target| 
        Puppet.debug "Sending status for #{self.host} to XMMP user #{target}"
        m = Message::new(target, body).set_type(:normal).set_id('1').set_subject("Puppet run failed!")
        cl.send m
      end
    end
  end

end
