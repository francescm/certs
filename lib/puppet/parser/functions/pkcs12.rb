module Puppet::Parser::Functions
  require 'fileutils'

  include FileUtils::Verbose
  newfunction(:pkcs12) do |args|
    hostname = lookupvar('hostname')
    secret = args[0]

    function_notice(["applying pkcs12 for #{hostname}"])
        if ! File.exists?("/etc/puppet/modules/certs/files/etc/ssl/pkcs12/#{hostname}.pkcs12")
	cmd = IO.popen("/usr/bin/ruby /etc/puppet/modules/certs/lib/puppet/parser/functions/pty_pkcs12.rb #{hostname} #{secret}")
        Puppet::Parser::Functions.autoloader.loadall
        err = cmd.read
        unless err.eql? ""
                raise Puppet::ParseError, "#{err}"
        end
    	function_notice(["pkcs12 created for #{hostname} with outcode #{err}"])

        FileUtils::cp("/tmp/#{hostname}.pkcs12", "/etc/puppet/modules/certs/files/etc/ssl/pkcs12/#{hostname}.pkcs12")
        FileUtils::rm_rf("/tmp/#{hostname}.pkcs12")
    end
  end
end

