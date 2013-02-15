class certs::pkcs12::keystore($secret, $passphrase) {

	file{'/etc/ssl/keystore':
		ensure => directory,
	}

	keytool($secret, $passphrase)

	file{"/etc/ssl/keystore/${hostname}.keystore":
		ensure => present,
		source => "puppet:///modules/certs/etc/ssl/keystore/${hostname}.keystore"
	}

}
