# frozen_string_literal: true

require_relative "external_service"
require_relative "lib/app"

xml_path = ARGV[0]

unless xml_path && File.file?(xml_path)
  warn "Use: ruby assignment.rb /path/to/feed.xml"
  exit 1
end

service = ExternalService.new
App.new(xml_path: xml_path, service: service).run
