Facter.add("confenv") do
  setcode do
    env = nil

    puppet_paths = [
      '/usr/bin/puppet',
      '/usr/local/bin/puppet',
      '/opt/puppet/bin/puppet',
      '/opt/csw/bin/puppet'
    ]
    path = puppet_paths.find { |puppet_path| File.exists? puppet_path }

    if path
      # Split it, in case it is PE. You can compare strings too, it's a little
      # dirty.
      if Facter.value( 'puppetversion' ).split( ' ' )[0] > "2.7"
        cmd = %{#{path} config print environment --mode agent}
      else
        cmd = %{#{path} agent --configprint environment}
      end
      env = Facter::Util::Resolution.exec(cmd).chomp
    end

    env
  end
end
