require_relative "base"
module Node
  class Literal < Base
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def to_ruby_hash
      value
    end
  end

  class String < Literal
  end

  class Number < Literal
  end

  class Null < Literal
  end

  class Boolean < Literal
  end
end
