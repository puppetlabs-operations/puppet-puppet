# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::dashboard {
  include ruby::dev
  include mysql::server
  
}
