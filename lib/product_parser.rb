# lib/product_parser.rb
# frozen_string_literal: true
require "nokogiri"
require "cgi"
require_relative "product"

class ProductParser
  G_NS = { "g" => "http://base.google.com/ns/1.0" }.freeze

  def initialize(xml_path)
    @xml_path = xml_path
  end

  def stream
    return to_enum(__method__) unless block_given?

    doc = File.open(@xml_path) { |f| Nokogiri::XML(f) }

    doc.css("item").each do |item|
      id = title = desc = nil

      item.element_children.each do |child|
        case child.name
        when "id"
          id = child.text.strip
        when "title"
          title = child.text.strip
        when "description"
          desc = child.text.strip
        end
      end

      next if id.to_s.empty? || title.to_s.empty?

      desc = CGI.unescapeHTML(desc) if desc
      yield Product.new(id: id, title: title, description: desc)
    end
  end
end
