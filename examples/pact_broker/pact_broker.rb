
if ARGV.first == 'client'
  require 'pact_broker/client/cli/broker'
  ARGV.shift

  if ENV['PACT_BROKER_DISABLE_SSL_VERIFICATION'] == 'true' || ENV['PACT_DISABLE_SSL_VERIFICATION'] == 'true'
    require 'openssl'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    $stderr.puts "WARN: SSL verification has been disabled by a dodgy hack (reassigning the VERIFY_PEER constant to VERIFY_NONE). You acknowledge that you do this at your own risk!"
  end

  class Thor
    module Base
      module ClassMethods
        def basename
          File.basename($PROGRAM_NAME).split(" ").first.chomp(".rb")
        end
      end
    end
  end

  if ENV['ORIG_SSL_CERT_DIR'] && ENV['ORIG_SSL_CERT_DIR'] != ''
    ENV['SSL_CERT_DIR'] = ENV['ORIG_SSL_CERT_DIR']
  end

  if ENV['ORIG_SSL_CERT_FILE'] && ENV['ORIG_SSL_CERT_FILE'] != ''
    ENV['SSL_CERT_FILE'] = ENV['ORIG_SSL_CERT_FILE']
  end

  PactBroker::Client::CLI::Broker.start
  exit
end

if ARGV.include?("--version")
  require "pact_broker/version"
  puts PactBroker::VERSION
  exit
end

unless ARGV.any? { |arg| arg =~ /\.ru$/ }
  ARGV.push("#{File.dirname(__FILE__)}/config.ru")
end
load Gem.bin_path("rackup", "rackup")
