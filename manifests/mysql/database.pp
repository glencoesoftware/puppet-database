define database::mysql::database (
  $dbname = $name,
  $privs = 'all',
  $allowed_hosts = [ 'localhost' ],
  $owner,
  $password
) {

  exec { 'create-db':
    command => "mysqladmin create ${dbname}",
    path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
  }

  database::mysql::create_user { $owner:
    allowed_privs => $allowed_privs,
    allowed_hosts => $allowed_hosts,
    password      => $password,
  }
}
