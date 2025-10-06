# frozen_string_literal: true

require "json"

class BatchBuilder
  BYTES_PER_MB   = 1_048_576
  MAX_BATCH_SIZE = 5 * BYTES_PER_MB

  def initialize
    @items = []
  end

  def push(product_hash)
    payloads = []

    tentative = @items + [product_hash]
    if json_size(tentative) < MAX_BATCH_SIZE
      @items << product_hash
      return payloads
    end

    flushed = finalize
    payloads << flushed if flushed

    if json_size([product_hash]) < MAX_BATCH_SIZE
      @items = [product_hash]
    else
      warn "Item #{product_hash[:id]} exceeds 5MB limit alone — ignored."
      @items = []
    end

    payloads
  end

  def finalize
    return nil if @items.empty?

    json = JSON.generate(@items)
    @items = []
    json
  end

  private

  def json_size(array)
    JSON.generate(array).bytesize
  end
end
