# frozen_string_literal: true

class Product
  attr_reader :id, :title, :description

  def initialize(id:, title:, description: nil)
    @id          = id
    @title       = title
    @description = description
  end

  def as_payload
    { id: @id, title: @title, description: @description }.compact
  end

  def valid?
    !@id.to_s.strip.empty? && !@title.to_s.strip.empty?
  end
end
