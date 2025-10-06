# frozen_string_literal: true

require_relative "product_parser"
require_relative "batch_builder"

class App
  def initialize(xml_path:, service:)
    @xml_path = xml_path
    @service  = service
  end

  def run
    parser  = ProductParser.new(@xml_path)
    batches = BatchBuilder.new

    parser.stream do |product|
      next unless product.valid?
      ready_payloads = batches.push(product.as_payload)
      ready_payloads.each { |json| @service.call(json) }
    end

    last = batches.finalize
    @service.call(last) if last
  end
end
