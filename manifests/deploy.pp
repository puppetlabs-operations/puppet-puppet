# Class: puppet::deploy
#
# This class installs and configures parameters for a curl|bash
# puppet install / deploy script
#
# Once this is installed, you can connect new nodes to the master using:
# curl https://puppetmaster.example.com/deploy | sudo bash
#
# (and then signing the cert on the master)
#
class puppet::deploy {
  # Use the puppet_install module to install a puppet deploy script that agents
  # can be installed with via a curl | bash command
  if $::puppet::webserver == 'webrick' {
    fail('puppet::deploy requires nginx or apache; standalone not supported')
  }
  class {'::puppet_installer':
    master    => $::fqdn,
    webserver => $::puppet::server::webserver,
    www_root  => $::puppet::params::puppet_confdir,
    ssl_cert  => "${::puppet::ssldir}/certs/${::fqdn}.pem",
    ssl_key   => "${::puppet::ssldir}/private_keys/${::fqdn}.pem",
  }
}
