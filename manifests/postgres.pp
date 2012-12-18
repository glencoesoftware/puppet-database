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
    "pg_hba.conf":
      path    => "/var/lib/pgsql/${version}/data/pg_hba.conf", 
      content => template("${module_name}/pg_hba.conf.erb"),
      require => Exec['initdb'],
      notify  => Service['postgres'],
      ;
    "postgresql.conf":
      path    => "/var/lib/pgsql/${version}/data/postgresql.conf",
      # content => template("${module_name}/postgresql.conf.erb"),
      source  => [ 
        "puppet:///modules/${module_name}/postgres/postgresql.conf.${fqdn}",
        "puppet:///modules/${module_name}/postgres/postgresql.conf",
      ],
      require => Exec['initdb'],
      notify  => Service['postgres'],
      ;
    "etc-postgres":
      path   => '/etc/postgres',
      ensure => 'directory',
      owner  => $pg_user,
      group  => $pg_group,
      ;
    'etc-postgresql.conf':
      ensure => 'link',
      path   => '/etc/postgres/postgresql.conf',
      target => "/var/lib/pgsql/${version}/data/postgresql.conf",
      owner  => $pg_user,
      group  => $pg_group,
      ;
    'etc-pg_hba.conf':
      ensure => 'link',
      path   => '/etc/postgres/pg_hba.conf',
      target => "/var/lib/pgsql/${version}/data/pg_hba.conf",
      owner  => $pg_user,
      group  => $pg_group,
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
