Facter.add("confenv") do
  setcode do
    env = nil

    if path = Facter.value(:puppet_path)
      # If we're looking at PE, then this will have a version string like this:
      #
      # 2.7.12 (Puppet Enterprise 2.5.1)
      #
      # We scan for things looking like semantic version strings then grab the first one.
      version = "#{Facter.value("puppet_major_version")}.#{Facter.value("puppet_minor_version")}"
      case version
      when "3.1"
        cmd = %{#{path} agent --configprint environment}
      when "3.0"
        cmd = %{#{path} config print environment --run_mode agent}
      when "2.7"
        cmd = %{#{path} config print environment --mode agent}
      when "2.6"
        cmd = %{#{path} agent --configprint environment}
      end

      if cmd and (output = Facter::Util::Resolution.exec(cmd))
        env = output.chomp
      end
    end

    env
  end
end
