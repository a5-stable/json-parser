require_relative "base"
module Node
  class JsonExpression < Base
    attr_accessor :pairs
    
    def initialize(pairs)
      @pairs = pairs
    end

    def to_ruby_hash
      pairs.inject({}) do |hash, pair|
        hash[pair.key.to_ruby_hash] = pair.value.to_ruby_hash
        hash
      end
    end
  end
end
