# frozen_string_literal: true

require "tempfile"
require_relative "../lib/product_parser"

RSpec.describe ProductParser do
  def write_xml(content)
    f = Tempfile.new(["feed", ".xml"])
    f.write(content)
    f.flush
    f
  end

  let(:xml_content) do
    <<~XML
      <?xml version='1.0' encoding='utf-8'?>
      <rss version='2.0' xmlns:g="http://base.google.com/ns/1.0">
        <channel>
          <item>
            <description>&lt;html&gt;Hello &amp; welcome&lt;/html&gt;</description>
            <g:id>4530607</g:id>
            <title>Blauwe jeans - skinny fit</title>
          </item>
          <item>
            <description>&lt;html&gt;Ignored because missing id&lt;/html&gt;</description>
            <title>No ID here</title>
          </item>
          <item>
            <description>&lt;html&gt;Second item&lt;/html&gt;</description>
            <g:id>999</g:id>
            <title>Second</title>
          </item>
        </channel>
      </rss>
    XML
  end

  it "yields valid products with unescaped description and g:id" do
    f = write_xml(xml_content)

    parser = ProductParser.new(f.path)
    products = parser.stream.to_a

    expect(products.size).to eq(2)

    first_h = products.first.as_payload
    expect(first_h[:id]).to eq("4530607")
    expect(first_h[:title]).to eq("Blauwe jeans - skinny fit")
    expect(first_h[:description]).to eq("<html>Hello & welcome</html>")

    second_h = products.last.as_payload
    expect(second_h[:id]).to eq("999")
    expect(second_h[:title]).to eq("Second")
    expect(second_h[:description]).to eq("<html>Second item</html>")
  end
end
