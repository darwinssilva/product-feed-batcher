# frozen_string_literal: true

require_relative "../lib/product"

RSpec.describe Product do
  it "is valid with id and title" do
    p = Product.new(id: "123", title: "Shoe", description: "<html>...</html>")
    expect(p.valid?).to be true
    expect(p.as_payload).to eq({ id: "123", title: "Shoe", description: "<html>...</html>" })
  end

  it "is invalid without id" do
    p = Product.new(id: nil, title: "X", description: nil)
    expect(p.valid?).to be false
  end

  it "is invalid without title" do
    p = Product.new(id: "1", title: "   ", description: nil)
    expect(p.valid?).to be false
  end
end
