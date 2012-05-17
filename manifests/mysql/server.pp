# mysql server
#
class database::mysql::server {
  package {
    'mysql-server':
      ensure => 'installed',
      name   => 'mysql-server',
      ;
  }

  service { 'mysql':
    ensure     => 'running',
    name       => 'mysqld',
    hasstatus  => 'true',
    hasrestart => 'true',
    require    => Package['mysql-server'],
  }

  exec { 'secure-install':
    command => 'secure_mysql'
    path    => [ '/root/bin', '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
    creates => "${mysql_data_dir}/.secured",
    require => Service['mysql'],
  }

  $mysql_extras = hiera('mysql_extras', false)
  if $mysql_extras {
    package {
      'mysql-report':
        name => 'msyqlreport'
        ;
      'mysql-top':
        name => 'mtop',
        ;
      'mysql-innodb-top':
        name => 'innotop',
        ;
      'mysql-maatkit':
        name => 'maatkit',
        ;
    }
  }
}
