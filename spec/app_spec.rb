# frozen_string_literal: true

require "json"
require "tempfile"
require_relative "../lib/app"
require_relative "../external_service"

class FakeService
  attr_reader :payloads
  def initialize
    @payloads = []
  end

  def call(batch_json)
    @payloads << batch_json
  end
end

RSpec.describe App do
  def write_xml(content)
    f = Tempfile.new(["feed", ".xml"])
    f.write(content)
    f.flush
    f
  end

  it "sends all products in one or more batches < 5MB" do
    xml = <<~XML
      <?xml version='1.0' encoding='utf-8'?>
      <rss version='2.0' xmlns:g="http://base.google.com/ns/1.0">
        <channel>
          <item>
            <description>&lt;html&gt;One&lt;/html&gt;</description>
            <g:id>1</g:id>
            <title>A</title>
          </item>
          <item>
            <description>&lt;html&gt;Two&lt;/html&gt;</description>
            <g:id>2</g:id>
            <title>B</title>
          </item>
          <item>
            <description>&lt;html&gt;Three&lt;/html&gt;</description>
            <g:id>3</g:id>
            <title>C</title>
          </item>
        </channel>
      </rss>
    XML

    f = write_xml(xml)
    begin
      service = FakeService.new
      app = App.new(xml_path: f.path, service: service)
      app.run

      expect(service.payloads).not_to be_empty
      total_items = service.payloads.sum { |p| JSON.parse(p).size }
      expect(total_items).to eq(3)

      service.payloads.each do |p|
        expect(p.bytesize).to be < 5 * 1_048_576
      end
    ensure
      f.close!
    end
  end
end
