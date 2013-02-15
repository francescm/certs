module Puppet::Parser::Functions
  require 'fileutils'

  include FileUtils::Verbose
  newfunction(:keytool) do |args|
    hostname = lookupvar('hostname')
    secret = args[0]
    passphrase = args[1]

    function_notice(["applying keytool for #{hostname}"])
        if ! File.exists?("/etc/puppet/modules/certs/files/etc/ssl/keytool/#{hostname}.keytool")
	cmd = IO.popen("/usr/bin/ruby /etc/puppet/modules/certs/lib/puppet/parser/functions/pty_keytool.rb #{hostname} #{secret} #{passphrase}")
        Puppet::Parser::Functions.autoloader.loadall
        err = cmd.read
        unless err.eql? ""
                raise Puppet::ParseError, "#{err}"
        end
    	function_notice(["keytool created for #{hostname} with outcode #{err}"])

        FileUtils::cp("/tmp/#{hostname}.keystore", "/etc/puppet/modules/certs/files/etc/ssl/keystore/#{hostname}.keystore")
        FileUtils::rm_rf("/tmp/#{hostname}.keystore")
    end
  end
end

