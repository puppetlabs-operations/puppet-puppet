Facter.add("confenv") do
  setcode do

    path = nil
    # We should change this to grab $puppet::params::puppet_cmd
    [ '/usr/bin/puppet', '/usr/local/bin/puppet', '/opt/puppet/bin/puppet', '/opt/csw/bin/puppet' ].each do |puppet|
      if File.exists?( puppet )
        path = puppet
        break
      end
    end

    return "problem with environment" if path.nil?

    # Split it, in case it is PE. You can compare strings too, it's a little
    # dirty.
    if Facter.value( 'puppetversion' ).split( ' ' )[0] > "2.7"
      env = %x{#{path} config print environment --mode agent}.chomp
    else
      env = %x{#{path} agent --configprint environment}.chomp
    end

    env

  end
end
