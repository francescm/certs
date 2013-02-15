#!/usr/bin/env ruby
#encodings: UTF-8

require 'fileutils'
require 'pty'
require 'expect'
STDOUT.sync     = true
STDERR.sync     = true
#$expect_verbose = true

include FileUtils

#raise "Usage: sudo ruby #{__FILE__} cert" if ! ARGV[0] 
hostname = ARGV[0]
secret = ARGV[1]

%x{cat /etc/puppet/modules/certs/files/etc/ssl/certs/#{hostname}.pem /etc/ssl/certs/tcs-chain.pem > /tmp/cert-chain-#{hostname}.txt}
cmd = "openssl pkcs12 -export -inkey /etc/puppet/modules/certs/files/etc/ssl/private/#{hostname}.key -in /tmp/cert-chain-#{hostname}.txt -out /tmp/#{hostname}.pkcs12"


PTY.spawn(cmd) do |reader, writer, pid|
  writer.sync = true
  reader.expect(/Enter Export Password:/) do |m|
    writer.puts secret
  end
  reader.expect(/Verifying - Enter Export Password:/) do |m|
    writer.puts secret
  end
  sleep 1
end

