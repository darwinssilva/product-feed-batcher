# frozen_string_literal: true

require "json"

class BatchBuilder
  BYTES_PER_MB   = 1_048_576
  MAX_BATCH_SIZE = 5 * BYTES_PER_MB

  def initialize
    @items = []
    @current_size = 2  # "[]" empty array
  end

  def push(product_hash)
    payloads = []

    item_json = JSON.generate(product_hash)
    item_size = item_json.bytesize
    tentative_size = @current_size + item_size + (@items.empty? ? 0 : 1)  # +1 for comma

    if tentative_size < MAX_BATCH_SIZE
      @items << product_hash
      @current_size = tentative_size
      return payloads
    end

    flushed = finalize
    payloads << flushed if flushed

    if item_size + 2 < MAX_BATCH_SIZE
      @items = [product_hash]
      @current_size = item_size + 2
    else
      warn "Item #{product_hash[:id]} exceeds 5MB limit alone — ignored."
      @items = []
      @current_size = 2
    end

    payloads
  end

  def finalize
    return nil if @items.empty?

    json = JSON.generate(@items)
    @items = []
    @current_size = 2
    json
  end
end
