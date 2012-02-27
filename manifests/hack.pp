class puppet::hack {

  # fix facter.
  if $::operatingsystem == 'debian' or $::operatingsystem == 'ubuntu'
  {
    if $::facterversion == '1.6.6' {
      # Patch facter.
      file{ '/usr/lib/ruby/1.8/facter/virtual.rb':
        source => 'puppet:///modules/puppet/virtual.rb'
      }
    }
  }

}
