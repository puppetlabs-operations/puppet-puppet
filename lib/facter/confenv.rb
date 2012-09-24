Facter.add("confenv") do
  setcode do
    env = nil

    if path = Facter.value(:puppet_path)
      # If we're looking at PE, then this will have a version string like this:
      #
      # 2.7.12 (Puppet Enterprise 2.5.1)
      #
      # We scan for things looking like semantic version strings then grab the first one.
      version = Facter.value('puppetversion').scan(/\d+\.\d+/).first.to_f
      case version
      when 3.0
        cmd = %{#{path} config print environment --run_mode agent}
      when 2.7
        cmd = %{#{path} config print environment --mode agent}
      when 2.6
        cmd = %{#{path} agent --configprint environment}
      end
      env = Facter::Util::Resolution.exec(cmd).chomp
    end

    env
  end
end
