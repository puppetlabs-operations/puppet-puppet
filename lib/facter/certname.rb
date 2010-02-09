Facter.add("certname") do
  setcode do
    %x{/usr/sbin/puppetmasterd --configprint certname}.chomp
  end
end

