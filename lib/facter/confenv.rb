Facter.add("confenv") do
  setcode do
    env = nil

    if path = Facter.value(:puppet_path)
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
