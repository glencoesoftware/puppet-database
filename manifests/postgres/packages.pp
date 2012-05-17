#
class database::postgres::packages {
  case $operatingsystem {
    /CentOS|RedHat/: {

      # remove the '.' from the version
      $version = $database::postgres::version
      $package_version = regsubst($database::postgres::version, '^(\d+)\.(\d+)', '\1\2')
      $release_pkg_name = $database::postgres::release_pkg_name

      package {
        'postgres-release':
          name     => $release_pkg_name,
          ;
        'postgres':
          name    => "postgresql${package_version}",
          require => Package['postgres-release'],
          ;
        'postgres-server':
          name    => "postgresql${package_version}-server",
          require => Package['postgres'],
          ;
        'postgresql-devel':
          name   => "postgresql${package_version}-devel",
          require => Package['postgres'],
          ;
      }
    }
    default: {
      err "operating system ${operatingsystem} not support"
    }
  }
}
