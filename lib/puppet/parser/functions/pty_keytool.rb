#!/usr/bin/env ruby
#encoding: UTF-8

require 'fileutils'
require 'pty'
require 'expect'
require 'puppet'
require 'logger'
STDOUT.sync     = true
STDERR.sync     = true
#$expect_verbose = true

include FileUtils

log_file = File.new('/tmp/foo.log', 'a')
logger = Logger.new(log_file, 'weekly')
$stderr = log_file 
$stdout = log_file 

logger.info("called keytool")

#raise "Usage: sudo ruby #{__FILE__} hostname secret cert" if ! ARGV[2] 

hostname = ARGV[0]
secret = ARGV[1]
passphrase = ARGV[2]

destfile = "/tmp/#{hostname}.keystore"
FileUtils::rm_rf destfile if File.exist?(destfile)

raise Puppet::ParseError, "Password too short" if passphrase.size < 6
raise Puppet::ParseError, "keystore already exists" if File.exist?(destfile)

cmd= "keytool -importkeystore -srckeystore /etc/puppet/modules/certs/files/etc/ssl/pkcs12/#{hostname}.pkcs12 -srcstoretype PKCS12 -destkeystore #{destfile}"

logger.info { cmd }

PTY.spawn(cmd) do |reader, writer, pid|
  writer.sync = true
  reader.expect(/Enter destination keystore password:/) do |m|
    writer.puts passphrase
    logger.info { "first #{passphrase}" }
  end
  reader.expect(/Re-enter new password:/) do |m|
    writer.puts passphrase
    logger.info { "second #{passphrase}" }
  end
  reader.expect(/Enter source keystore password:/) do |m|
    writer.puts secret
    logger.info { secret }
  end

  sleep 1
end

%x{keytool -changealias -alias 1 -destalias "#{hostname}" -keystore /tmp/#{hostname}.keystore -storepass #{passphrase}}
%x{keytool -keystore /tmp/#{hostname}.keystore -keypasswd -alias #{hostname} -keypass #{secret} -new #{passphrase} -storepass #{passphrase}}


