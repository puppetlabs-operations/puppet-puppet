Facter.add("certname") do
  masterpath = '/usr/sbin/puppetmasterd'
  setcode do
    %x{#{masterpath} --configprint certname}.chomp if File.exists?(masterpath)
  end
end

