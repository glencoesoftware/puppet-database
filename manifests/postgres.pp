class database::postgres (
  $version = hiera('postgres_version', '9.1'),
  $release_pkg_name = hiera('postgres_release_package', 'pgdg-centos91'),
  $pg_user = hiera('postgres_user', 'postgres'),
  $service_name = hiera('postgres_custom_service_name', ''),
) {
  
  # install classes
  class { 'database::postgres::packages': }

  $pg_service_name = $service_name ? {
    ''      => "postgresql-${version}",
    default => $service_name
  }

  $vardir = "/var/lib/pgsql/${version}"
  $bindir = "/usr/pgsql-${version}/bin"

  File { 
    owner   => $pg_user,
    group   => $pg_user,
    require => Class['database::postgres::packages'],
  }

  # this may only work on rhel/centos (depends on initscript)
  exec {
    'initdb':
      command     => "service ${pg_service_name} initdb en_US.UTF-8",
      path        => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin', "${bindir}" ],
      creates     => "${vardir}/data/PG_VERSION",
      environment => [ 'LANG=en_US.UTF-8' ],
      require     => Class['database::postgres::packages'],
      ;
  }

  file {
    "/var/lib/pgsql/${version}/data/pg_hba.conf":
      content => template("${module_name}/pg_hba.conf.erb"),
      require => Exec['initdb'],
      notify  => Service['postgres'],
      ;
  }

  service { 'postgres':
    name       => $pg_service_name,
    ensure     => 'running',
    enable     => 'true',
    hasrestart => 'true',
    hasstatus  => 'true',
    restart    => "/sbin/service ${pg_service_name} reload",
    require    => Exec['initdb'],
  }
}
