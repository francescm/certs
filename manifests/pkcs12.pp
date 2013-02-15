class certs::pkcs12($secret) {

	file{'/etc/ssl/pkcs12':
		ensure => directory,
	}

	pkcs12($secret)

	file{"/etc/ssl/pkcs12/${hostname}.pkcs12":
		ensure => present,
		source => "puppet:///modules/certs/etc/ssl/pkcs12/${hostname}.pkcs12"
	}

}
