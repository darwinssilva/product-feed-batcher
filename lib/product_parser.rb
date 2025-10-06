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

    File.open(@xml_path) do |file|
      Nokogiri::XML::Reader(file).each do |node|
        next unless node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT && node.name == "item"

        item_doc = Nokogiri::XML(node.outer_xml)

        id_node    = item_doc.at_xpath("//item/g:id", G_NS)
        title_node = item_doc.at_xpath("//item/title")
        desc_node  = item_doc.at_xpath("//item/description")

        id    = id_node&.text&.strip
        title = title_node&.text&.strip
        desc  = desc_node ? CGI.unescapeHTML(desc_node.text.to_s.strip) : nil

        next if id.to_s.empty? || title.to_s.empty?

        yield Product.new(id: id, title: title, description: desc)
      end
    end
  end
end
