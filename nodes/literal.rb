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
end
