module Node
  class Literal
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  end

  class String < Literal
  end

  class Number < Literal
  end

  class Null < Literal
    NULL_STRING = "null"
  end

  class Boolean < Literal
    TRUE_STRING = "true"
    FALSE_STRING = "false"
  end
end
