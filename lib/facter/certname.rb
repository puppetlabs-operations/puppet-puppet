Facter.add("certname") do
  setcode do
    %x{/usr/bin/puppetmasterd --configprint certname}.chomp
  end
end

