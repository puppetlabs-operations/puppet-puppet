Facter.add("certname") do
  masterpath = '/usr/bin/puppetmasterd'
  setcode do
    %x{#{masterpath} --configprint certname}.chomp if File.exists?(masterpath)
  end
end

