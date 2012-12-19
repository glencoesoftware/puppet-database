# Class: database::postgres::replication
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
class database::postgres::replication inherits database::postgres {
  # generic replication settings go here
  # replication dbs need to have keys
  file {
    "${vardir}/.ssh":
      ensure => 'directory',
      mode   => '0700',
      ;
    'ssh_private_key':
      path   => "${vardir}/.ssh/id_rsa",
      mode   => '0600',
      source => "puppet:///modules/${module_name}/postgres-ssh-privatekey.key",
      ;
  }

  notice "pguser: ${pg_user}"
  ssh_authorized_key { 'ssh_key_postgres':
    ensure => 'present',
    user   => $pg_user,
    type   => 'ssh-rsa',
    key    => hiera('postgres_ssh_pubkey'),
  }
}
