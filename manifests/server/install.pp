# PRIVATE CLASS: do not call directly
class postgresql::server::install {
  $package_ensure      = $postgresql::server::package_ensure
  $package_name        = $postgresql::server::package_name
  $client_package_name = $postgresql::server::client_package_name

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default => $package_ensure,
  }

  package { 'postgresql-server':
    ensure => $_package_ensure,
    name   => $package_name,

    # This is searched for to create relationships with the package repos, be
    # careful about its removal
    tag    => 'postgresql',
  }

  if $::osfamily == 'Darwin' {
    $_file_ensure = $package_ensure ? {
      true     => 'file',
      false    => 'absent',
      'absent' => 'absent',
      default  => 'file',
    }

    # Template variables
    $service_name = $postgresql::server::service_name
    $bindir       = $postgresql::params::bindir
    $datadir      = $postgresql::server::datadir
    $user         = $postgresql::server::user
    $group        = $postgresql::server::group

    file { $postgresql::params::service_rc:
      ensure => $_file_ensure,
      owner  => 'root',
      group  => '0',
      mode   => '0644',
      content => template($postgresql::params::service_erb),
    }
  }

}
