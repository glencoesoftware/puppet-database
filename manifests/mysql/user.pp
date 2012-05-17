define database::mysql::user (
  $ensure = 'present',
  $owner = $name,
  $password,
) {
  case $ensure {
    'present': {
      exec { 'create-user':
        command => "mysql --execute='create user ${owner} identified by \'${password}\';' --database=mysql",
      }
    }
    'absent': {
      exec { 'destroy-user':
        command => "mysql --execute='drop user ${owner}' --database=mysql",
      }
    }
  }
}
