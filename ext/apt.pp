apt::source { 'puppet':
  location    => 'http://apt.terrarum.net/ubuntu',
  release     => $::lsbdistcodename,
  repos       => 'main',
  key         => 'F8793AF4',
  key_server  => 'subkeys.pgp.net',
  include_src => false,
}
