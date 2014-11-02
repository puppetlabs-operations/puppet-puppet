# Configure the trapperkeeper-based embedded webserver in puppetserver
# https://github.com/puppetlabs/trapperkeeper-webserver-jetty9/blob/master/doc/jetty-config.md

class puppet::server::puppetserver::webserver (
  $host                    = undef,
  $port                    = undef,
  $max_threads             = undef,
  $request_header_max_size = undef,
  $ssl_host                = undef,
  $ssl_port                = undef,
  $ssl_cert                = undef,
  $ssl_cert_chain          = undef,
  $ssl_key                 = undef,
  $ssl_ca_cert             = undef,
  $keystore                = undef,
  $key_password            = undef,
  $truststore              = undef,
  $trust_password          = undef,
  $cipher_suites           = undef,
  $ssl_protocols           = undef,
  $client_auth             = undef,
  $ssl_crl_path            = undef,
  $static_content          = undef
) {
  include puppet
  include puppet::server
  include puppet::server::puppetserver

}
