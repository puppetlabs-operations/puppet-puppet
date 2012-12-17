Facter.add("ca") do
  setcode do
    ca = nil

    if path = Facter.value(:puppet_path)
      # If we're looking at PE, then this will have a version string like this:
      #
      # 2.7.12 (Puppet Enterprise 2.5.1)
      #
      # We scan for things looking like semantic version strings then grab the first one.
      version = Facter.value('puppetversion').scan(/\d+\.\d+/).first.to_f
      case version
      when 3.0
        cmd = %{#{path} config print ca --run_mode master}
      when 2.7
        cmd = %{#{path} config print ca --mode master}
      when 2.6
        cmd = %{#{path} master --configprint ca}
      end

      if output = Facter::Util::Resolution.exec(cmd)
        ca = output.chomp
      end
    end

    ca
  end
end
