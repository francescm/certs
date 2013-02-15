class certs {

if $operatingsystem == 'Debian' or $lsbdistid == 'Debian' {

$key = "/etc/ssl/private/${hostname}.key"
$cert = "/etc/ssl/certs/${hostname}.pem"

file { $key:
	ensure => file,
	source => "puppet:///modules/certs/$key",	
	mode => "640",
	owner => "root",
	group => "Debian-exim"
	}

file { "/etc/ssl/certs/tcs-chain.pem":
	ensure => file,
	mode => "644",
	source => "puppet:///modules/certs/etc/ssl/certs/tcs-chain.pem"
	}

file { "/etc/ssl/private/":
	ensure => directory,
	mode => "710",
	group => "Debian-exim"
	}

file { $cert:
	ensure => file,
	source => "puppet:///modules/certs/$cert",
	mode => "644"
	}
}
}
