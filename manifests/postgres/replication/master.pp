# Class: manifests::postgres::replication::master
#
# This class does stuff that you describe here
#
# Parameters:
#   $parameter:
#       this global variable is used to do things
#
# Actions:
#   Actions should be described here
#
# Requires:
#   - Package["foopackage"]
#
# Sample Usage:
#
class database::postgres::replication::master inherits database::postgres {
  file { 'recovery.conf':
    ensure => 'absent',
    path   => "/var/lib/pgsql/${version}/data/recovery.conf",
  }

  # must be defined
  $pg_replication_slave = hiera('postgres_replication_slave')
}
