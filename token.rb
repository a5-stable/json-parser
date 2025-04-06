class Token
  attr_reader :type, :lexeme, :literal

  def initialize(type, lexeme, literal)
    @type = type
    @lexeme = lexeme
    @literal = literal
  end
end
