Puppet::Parser::Functions.newfunction(:interval, :type => :rvalue, :doc => <<EOT
time_interval
=============

Returns an array of evenly spaced but randomly selected numbers

Usage:
------

    interval(count, max)

  * count:  the number of values to return
  * max:    the upper limit of the random numbers, exclusive

Example:
--------

    # Generate three random numbers between 0 and 60
    $arr = interval(3, 60)
    # => [19, 39, 59]

EOT
) do |args|
  require 'digest/md5'

  count = Integer(args[0])
  max   = Integer(args[1])

  # Generate a constant seed
  fqdn            = lookupvar('::fqdn')
  calculated_seed = Digest::MD5.hexdigest(fqdn).hex
  # And apply it
  srand(calculated_seed)

  # Generate the first random number
  base = rand(max)

  # The difference to apply to each iteration
  diff = max / count


  offset = 0

  vals = []
  count.times do

    # Add the current offset to the base
    current = base + offset

    # Wrap around the current value if it exceeds the max
    wrapped = current % max

    # Save the value
    vals << wrapped

    # Increment the offset
    offset += diff
  end

  vals
end
