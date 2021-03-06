# Module DevOps
class devops {

	yumrepo { "EPEL":
	        baseurl  => absent,
	        mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch',
	       	descr    => "EPEL Official Repository",
	        enabled  => 1,
	        priority => 10,
	        failovermethod => 'priority',
	        gpgcheck => 0,
	}

	yumrepo { "IUS":
	        baseurl  => absent,
	        mirrorlist => 'https://mirrors.iuscommunity.org/mirrorlist?repo=ius-centos7&arch=$basearch&protocol=http',
	        descr    => "IUS Community Repository",
	        enabled  => 1,
	        priority => 1,
	        failovermethod => 'priority',
	        gpgcheck => 0,
	}

	yumrepo { "NGinx":
	        baseurl  => 'http://nginx.org/packages/centos/7/$basearch/',
	        descr    => "NGinx Official Repository",
	        enabled  => 1,
	        priority => 1,
	        failovermethod => 'priority',
	        gpgcheck => 0,
	}

	group { 'puppet':
	        ensure => present,
	}

	exec { 'yum update':
	        command => '/usr/bin/yum update -y',
	}

	package { 'nginx':
	        ensure => present,
	        require => [ Exec['yum update'], Yumrepo['NGinx'] ],
	}

	package { 'php7*':
	        ensure => present,
	        require => [ Exec['yum update'], Yumrepo ['IUS'] ],
	}
	
	service { 'nginx':
	        ensure => running,
	        require => Package['nginx'],
		hasrestart => true,
		#require    => File['/etc/nginx/nginx.conf'],
		restart    => 'systemctl restart nginx.service',
	}
	
	service { 'php-fpm':
	        ensure => running,
	        require => Package['php7*'],
	}
	
	file { 'nginx/conf.d':
	     path => '/etc/nginx/conf.d',
	     ensure => directory,
	     require => Package['nginx'],
	}
	
	file { 'nginx/default.d':
	     ensure  => directory,
	     path    => '/etc/nginx/default.d',
	     require => Package['nginx'],
	}
	
	file { 'nginx/nginx.conf':
	     ensure  => present,
	     path    => '/etc/nginx/nginx.conf',
	     require => Package['nginx'],
	}
	
	file { 'nginx-proxy.conf':
	     ensure  => present,
	     path    => '/etc/nginx/conf.d/nginx-proxy.conf',
	     require => Package['nginx'],
	     notify  => Service['nginx'],
	     source  => 'puppet:///modules/devops/nginx-proxy.conf',
	}

	file { 'nginx/conf.d/default.conf':
		path    => '/etc/nginx/conf.d/default.conf',
		ensure  => absent,
		notify  => Service['nginx'],
		require => Package['nginx'],
	}

        file { 'nginx/conf.d.d/php-fpm.conf':
                path    => '/etc/nginx/conf.d/php-fpm.conf',
                ensure  => absent,
                notify  => Service['nginx'],
                require => Package['nginx'],
        }

        file { 'nginx/default.d/php.conf':
                path    => '/etc/nginx/default.d/php.conf',
                ensure  => absent,
                notify  => Service['nginx'],
                require => Package['nginx'],
        }
}
