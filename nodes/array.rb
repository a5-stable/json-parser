require_relative "base"
module Node
  class Array < Base
    attr_accessor :elements

    def initialize(elements)
      @elements = elements
    end

    def to_ruby_hash
      elements.map(&:to_ruby_hash)
    end
  end
end
