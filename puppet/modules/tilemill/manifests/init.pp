class tilemill {
    include apt

    $user = 'tilemill'
    $user_directory = "/srv/${user}"

    exec { "add-apt" :
      command => "/usr/bin/add-apt-repository -y ppa:developmentseed/mapbox && /usr/bin/apt-get update",
      subscribe => Package["python-software-properties"]
    }

    package { "libmapnik" : ensure => "installed", subscribe => Exec['add-apt'] }
    package { "tilemill" : ensure => "latest", subscribe => Exec['add-apt'] }
    package { "nodejs" : ensure => "latest", subscribe => Exec['add-apt'] }

	user { $user :
		home => $user_directory,
		ensure => present,
		shell => "/bin/bash",
	}

	file { $user_directory :
		ensure 	=> directory,
		owner 	=> $user,
		group 	=> $user,
		mode => 775,
		require => User[$user]
	}

    file { "tilemill.init" :
        path => "/etc/init/tilemill.conf",
        content => template("tilemill/tilemill-init.erb"),
        require => Package['tilemill'],
    }

    file { "tilemill.config" :
        path => "/etc/tilemill/tilemill.config",
        content => template("tilemill/tilemill-config.erb"),
        require => Package['tilemill'],
    }

    service { "tilemill" :
        provider => "upstart",
        ensure => "running",
        enable => true,
        require => File["tilemill.config"],
    }
}