Facter.add("certname") do
  path = '/usr/bin/puppet'
  setcode do
    %x{#{path} --configprint certname}.chomp if File.exists?(path)
  end
end

