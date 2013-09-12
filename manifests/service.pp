# Class: nginx::service
#
# This module manages NGINX service management and vhost rebuild
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::service(
  $configtest_enable = $nginx::params::nx_configtest_enable,
  $service_restart   = $nginx::params::nx_service_restart
) {

  $command = '${#files[*]}'
  exec { 'rebuild-nginx-vhosts':
    command     => "/bin/cat ${nginx::params::nx_temp_dir}/nginx.d/* > ${nginx::params::nx_vhost_dir}/vhost_autogen.conf",
    path        => ["/usr/bin", "/usr/sbin", '/bin/'],
    provider    => 'shell',
    refreshonly => true,
    unless      => "shopt -s nullglob dotglob && files=(${nginx::params::nx_temp_dir}/nginx.d/*) && ! (( ${command} )) && shopt -u nullglob dotglob",
    subscribe   => File["${nginx::params::nx_temp_dir}/nginx.d"],
  }
  exec { 'rebuild-nginx-mailhosts':
    command     => "/bin/cat ${nginx::params::nx_temp_dir}/nginx.mail.d/* > ${nginx::params::nx_conf_dir}/conf.mail.d/vhost_autogen.conf",
    refreshonly => true,
    provider    => 'shell',
    unless      => "shopt -s nullglob dotglob && files=(${nginx::params::nx_temp_dir}/nginx.mail.d/*) && ! (( ${command} )) && shopt -u nullglob dotglob",
    subscribe   => File["${nginx::params::nx_temp_dir}/nginx.mail.d"],
  }
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Exec['rebuild-nginx-vhosts', 'rebuild-nginx-mailhosts'],
  }
  if $configtest_enable == true {
    Service['nginx'] {
      restart => $service_restart,
    }
  }
}
