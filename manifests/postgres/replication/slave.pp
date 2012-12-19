# Class: database::postgres::replication::slave
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
class database::postgres::replication::slave {
  # these should not have defaults so that they fail when not specified
  $pg_replication_master = hiera_hash('postgres_replication_master')
  $pg_restore_command = hiera('postgres_restore_command')

  file {
    'recovery.conf':
      path    => "/var/lib/pgsql/${version}/data/recovery.conf",
      content => template("${module_name}/recovery.conf.erb"),
      ;
  }
}
