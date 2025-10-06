# frozen_string_literal: true

require "json"
require_relative "../lib/batch_builder"

RSpec.describe BatchBuilder do
  let(:builder) { described_class.new }

  def make_item(id:, title_len: 10, desc_len: 100)
    {
      id: id.to_s,
      title: "T" * title_len,
      description: "<html>" + ("D" * desc_len) + "</html>"
    }
  end

  it "accumulates items until just below MAX and then flushes" do
    flushed = []

    50.times do |i|
      payloads = builder.push(make_item(id: i))
      flushed.concat(payloads)
    end

    flushed.each do |json|
      expect(json.bytesize).to be < BatchBuilder::MAX_BATCH_SIZE
      arr = JSON.parse(json)
      expect(arr).to all(include("id", "title", "description"))
    end
  end

  it "ignores a single item that alone exceeds MAX" do
    big_desc = "X" * (BatchBuilder::MAX_BATCH_SIZE)
    payloads = builder.push({ id: "HUGE", title: "A", description: big_desc })

    expect(payloads).to eq([])

    last = builder.finalize
    expect(last).to be_nil
  end
end
