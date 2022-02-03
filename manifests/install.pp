# == Class: varnish::install
#
# Installs Varnish.
#
# === Parameters
#
# version - passed to puppet type 'package', attribute 'ensure'
#
# === Examples
#
# install Varnish
# class {'varnish::install':}
#
# make sure latest version is always installed
# class {'varnish::install':
#  version => latest,
# }
#

class varnish::install (
  Boolean $add_repo = true,
  Boolean $manage_firewall = false,
  Stdlib::Port  $varnish_listen_port = 6081,
  Optional[String]  $package_name = undef,
  Boolean $varnish_enterprise = false,
  Boolean $varnish_enterprise_vmods_extra = false,
  String  $version = 'present',
) {
  class { 'varnish::repo':
    enable  => $add_repo,
    version =>  $version,
    before  => Package['varnish'],
  }

  class { 'varnish::firewall':
    manage_firewall     => $manage_firewall,
    varnish_listen_port => $varnish_listen_port,
  }
  #Custom Package Name defined
  if($package_name) {
    package { 'varnish':
      ensure => $version,
      name   => $package_name,
    }
  }
  else { #let the module decide
    if($varnish_enterprise) {
      $package_ensure = 'varnish-plus'
      $package_absent = 'varnish'
      if($varnish_enterprise_vmods_extra) {
        package { 'varnish-plus-vmods-extra':
          ensure  => 'present',
          name    => 'varnish-plus-vmods-extra',
          require => Package['varnish'],
        }
      }
    }
    else {
      $package_ensure = 'varnish'
      $package_absent = 'varnish-plus'
    }
    package { 'varnish-absent':
      ensure => 'absent',
      name   => $package_absent,
      before => Package['varnish'],
    }
    package { 'varnish':
      ensure => $version,
      name   => $package_ensure,
    }
  }
}
