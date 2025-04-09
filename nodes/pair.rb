require_relative "base"
module Node
  class Pair < Base
    attr_reader :key, :value

    def initialize(key, value)
      @key = key
      @value = value
    end

    def to_ruby_hash
      {key => value}
    end
  end
end
