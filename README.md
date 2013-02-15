= Puppet module to convert openssl certs to keystore =

This is just a wrap-up of the needed commands to create a java keystore starting from a openssl x509 cert, file and chain. 
 
Chain is supposed to be "tcs-chain.pem", change in source according your needs.

== Openssl/Keytool recap ==

Export x509 to pksc12:
<pre>
cat /etc/puppet/modules/certs/files/etc/ssl/certs/#{hostname}.pem /etc/ssl/certs/tcs-chain.pem > /tmp/cert-chain-#{hostname}.txt
openssl pkcs12 -export -inkey /etc/puppet/modules/certs/files/etc/ssl/private/#{hostname}.key -in /tmp/cert-chain-#{hostname}.txt -out /tmp/#{hostname}.pkcs12
</pre>
Import pkcs12 to kestore:
<pre>
keytool -importkeystore -srckeystore /etc/puppet/modules/certs/files/etc/ssl/pkcs12/#{hostname}.pkcs12 -srcstoretype PKCS12 -destkeystore #{destfile}
</pre>
Fix keypass:
<pre>
keytool -keypasswd -alias 1 -keypass #{secret} -new #{passphrase} -keystore /path/to/keystore -storepass #{passphrase}
</pre>
This step is very important. Activemq sslContext expect passphrase and keypass to be the same. Before that, keypass is the export password you typed in openssl pkcs12 command.

Fix alias name:
<pre>
keytool -changealias -alias 1 -destalias #{hostname} -keypass #{passphrase} -keystore /path/to/keystore -storepass #{passphrase}
</pre>
List certificates:
<pre>
keytool -list -keystore #{hostname}.store -storepass #{passphrase}
</pre>

== Howto use it with puppet ==

Place cert and key in files/etc/ssl/certs and files/etc/ssl/private respectly named after the ${hostname}.

Add in sites.pp something as:
<pre>
        class {'certs::pkcs12':
                secret => "exportsecret"
                }
        class {'certs::pkcs12::keystore':
                secret => "exportsecret",
                passphrase => "bluehorror"
                }
</pre>