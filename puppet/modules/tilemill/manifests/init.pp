class tilemill {
    include apt

    $user = 'tilemill'
    $user_directory = "/srv/${user}"
    $git_repo = 'https://github.com/ox-it/maps-tiles.git'
    $mapbox_project = '/usr/share/mapbox/project/maps-ox'

    exec { "add-apt" :
      command => "/usr/bin/add-apt-repository -y ppa:developmentseed/mapbox && /usr/bin/apt-get update",
      subscribe => Package["python-software-properties"]
    }

    package { "libmapnik" : ensure => "installed", subscribe => Exec['add-apt'] }
    package { "tilemill" : ensure => "latest", subscribe => Exec['add-apt'] }
    package { "nodejs" : ensure => "latest", subscribe => Exec['add-apt'] }

    # installing a few fonts
    package { ["fonts-cantarell", "lmodern", "ttf-aenigma", "ttf-georgewilliams", "ttf-bitstream-vera", "ttf-sjfonts", "ttf-tuffy", "tv-fonts", "ubuntustudio-font-meta"] :
        ensure => installed
    }

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
    
    exec { "git-clone-project" :
        command => "git clone ${git_repo} ${user_directory}/maps-tiles",
        user => 'tilemill',
        unless => "test -d ${user_directory}/maps-tiles",
        require => [File[$user_directory], Package['git']]
    }
    
    exec { "copy-to-mapbox" :
        command => "cp -R ${user_directory}/maps-tiles/maps-ox/ /usr/share/mapbox/project/maps-ox",
        user => 'mapbox',
        unless => "test -d /usr/share/mapbox/project/maps-ox",
        require => [Service['tilemill'], Exec['git-clone-project']]
    }

    exec { "copy-land" :
        command => "curl http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/physical/10m-land.zip > ${user_directory}/10m-land.zip",
        user => 'tilemill',
        unless => "test -f ${user_directory}/10m-land.zip",
        require => File[$user_directory],
    }

}