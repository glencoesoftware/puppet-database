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
    "/var/lib/pgsql/.ssh":
      ensure => 'directory',
      mode   => '0700',
      ;
    'ssh_private_key':
      path   => "/var/lib/pgsql/.ssh/id_rsa",
      mode   => '0600',
      source => "puppet:///modules/${module_name}/postgres-ssh-privatekey.key",
      ;
  }

  $pg_ssh_pubkey = hiera('postgres_ssh_pubkey')
  ssh_authorized_key { 'ssh_key_postgres':
    ensure => 'present',
    user   => $pg_user,
    type   => 'ssh-rsa',
    key    => $pg_ssh_pubkey,
  }

  $pg_replication_slave = hiera('postgres_replication_slave', '')
  $pg_replication_master = hiera('postgres_replication_master', '')

  if $pg_replication_slave {
    host { 'pg_standby':
      ip => $pg_replication_slave,
    }
  }

  if $pg_replication_master {
    host { 'pg_master':
      ip => $pg_replication_master,
    }
  }
}
