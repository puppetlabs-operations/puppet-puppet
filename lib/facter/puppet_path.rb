Facter.add(:puppet_path) do
  setcode do
    puppet_paths = [
      '/usr/bin/puppet',
      '/usr/local/bin/puppet',
      '/opt/puppet/bin/puppet',
      '/opt/csw/bin/puppet'
    ]

    puppet_paths.find { |puppet_path| File.executable_real? puppet_path }
  end
end
