define database::postgres::db (
  $owner,
  $owner_pass,
  $dbname = $name,
  $ensure = 'present',
  $template_db = 'template1',
  $pg_user = hiera('postgres_user', 'postgres'),
  $version = hiera('postgres_version', '9.1'),
) {

  $pg_dir = "/usr/pgsql-${version}"
  $dbexists = "psql -l ${dbname}"

  database::postgres::owner { $owner:
    ensure   => $ensure,
    password => $owner_pass,
    version  => $version,
    pg_user  => $pg_user,
  }

  if $ensure == 'present' {

    exec {
      "createdb ${name}":
        command => "createdb -T ${template_db} -O ${owner} ${dbname}",
        path    => [ '/usr/bin', "${pg_dir}/bin" ],
        user    => $pg_user,
        unless  => $dbexists,
        require => Database::Postgres::Owner[$owner],
        ;
    }
    
    if $create_lang {
      exec {
        # this may be redundant in psql 9
        "createlang ${name}":
          command     => "createlang plpgsql ${dbname}",
          path        => [ '/usr/bin', "${pg_dir}/bin" ],
          user        => $pg_user,
          refreshonly => 'true',
          ;
      }
    }

  } elsif $ensure == 'absent' {

    exec { "dropdb $name":
      command => "dropdb $name",
      user => $pg_user,
      onlyif => $dbexists,
      before => Database::Postgres::Owner[$owner],
    }
  }
}
