# ensure that apt update is run before any packages are installed
class apt {
  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }

  # Ensure apt-get update has been run before installing any packages
  Exec["apt-update"] -> Package <| |>

}

package { "python-software-properties" : ensure => "installed"}
package { "build-essential" : ensure => "installed"}
package { "git" : ensure => "latest"}
package { "vim" : ensure => "latest"}
package { "supervisor" : ensure => "latest"}
package { "nginx-full" : ensure => "latest"}
package { ntp: ensure => installed }


include tilemill
include nginx

nginx::site { "default":
    ensure => absent,
}

$nginx_auth_password = '/srv/tilemill/nginx-auth-passwords'

file { $nginx_auth_password :
    source  => "puppet:///files/nginx-auth-passwords",
    require => User['tilemill']
}

nginx::site { 'tilemill-proxy':
   ensure  => present,
   content => template('tilemill/nginx-proxy-tilemill.erb'),
}
