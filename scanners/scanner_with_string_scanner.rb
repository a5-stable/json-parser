# require_relative "../token_type"
# require_relative "../token"
# require "strscan"

# class ScannerWithStringScanner
#   include TokenType
#   attr_accessor :json_string, :tokens, :string_scanner

#   def initialize(json_string)
#     @json_string = json_string
#     @tokens = []
#     @string_scanner = StringScanner.new(json_string)
#   end

#   def scan_tokens

#     while !string_scanner.eos?
#       scan_token
#     end

#     tokens
#   end

#   def scan_token
#     case string_scanner.peek(1)
#     when string_scanner.scan(/\{/)
#       add_token(TokenType::LEFT_BRACKET)
#     when string_scanner.scan(/\}/)
#       add_token(TokenType::RIGHT_BRACKET)
#     when string_scanner.scan(/:/)
#       add_token(TokenType::COLON)
#     when string_scanner.scan(/,/)
#       add_token(TokenType::COMMA)
#     when string_scanner.scan(/\[/)
#       add_token(TokenType::LEFT_ARRAY)
#     when string_scanner.scan(/\]/)
#       add_token(TokenType::RIGHT_ARRAY)
#     when string_scanner.scan(/\s+/)
#     when string_scanner.scan(/"/)
#       consume_string
#     else
#       if is_number?(string_scanner.peek(1))
#         consume_number
#       else
#         consume_identifier
#       end
#     end
#   end

#   private

#   def consume_string
#     start_pos = string_scanner.pos - 1
#     literal = string_scanner.scan(/[^"]*/)
#     string_scanner.scan(/\"/)
#     end_pos = string_scanner.pos

#     lexeme = string_scanner.string[start_pos...end_pos]
#     add_token(TokenType::STRING, lexeme: lexeme, literal: literal)
#   end

#   def consume_number
#     literal = string_scanner.scan(/[+-]?\d+(?:\.\d+)?/)
#     add_token(TokenType::NUMBER, literal: literal.to_f)
#   end

#   TOKEN_NULL_STRING = "null"
#   TOKEN_TRUE_STRING = "true"
#   TOKEN_FALSE_STRING = "false"
#   def consume_identifier
#     literal = string_scanner.scan(/[a-zA-Z_][a-zA-Z0-9_]*/)
#     case literal
#     when TOKEN_NULL_STRING
#       add_token(TokenType::NULL, literal: literal)
#     when TOKEN_TRUE_STRING, TOKEN_FALSE_STRING
#       add_token(TokenType::BOOLEAN, literal: literal)
#     else
#       binding.irb
#       raise "Unexpected identifier: #{literal}"
#     end
#   end

#   def add_token(type, lexeme: nil, literal: nil)
#     @tokens << Token.new(type, lexeme || string_scanner.matched, literal)
#   end

#   def is_number?(str)
#     str =~ /^[-0-9.]$/ ? true : false
#   end

#   def is_alphabet?(str)
#     str =~ /\A[a-zA-Z]+\z/
#   end
# end
require_relative "../token_type"
require_relative "../token"
require "strscan"

class ScannerWithStringScanner
  include TokenType
  attr_accessor :json_string, :tokens, :scanner

  def initialize(json_string)
    @json_string = json_string
    @tokens = []
    @scanner = StringScanner.new(json_string)
  end

  def scan_tokens
    while !scanner.eos?
      scan_token
    end
    tokens
  end

  def scan_token
    case
    when scanner.scan(/\s+/) # Skip spaces
      # Do nothing for spaces
    when scanner.scan(/\{/)  # Left bracket
      add_token(TokenType::LEFT_BRACKET)
    when scanner.scan(/\}/)  # Right bracket
      add_token(TokenType::RIGHT_BRACKET)
    when scanner.scan(/:/)  # Colon
      add_token(TokenType::COLON)
    when scanner.scan(/,/)  # Comma
      add_token(TokenType::COMMA)
    when scanner.scan(/\[/)  # Left array
      add_token(TokenType::LEFT_ARRAY)
    when scanner.scan(/\]/)  # Right array
      add_token(TokenType::RIGHT_ARRAY)
    when scanner.scan(/"/)  # String
      consume_string
    when scanner.scan(/[-0-9.]/)  # Number
      consume_number
    else
      consume_identifier
    end
  end

  private

  def consume_string
    literal = ''
    while char = scanner.getch
      break if char == '"'
      literal += char
    end

    if scanner.eos?
      raise "unfinished string literal"
    end

    add_token(TokenType::STRING, literal: literal)
  end

  def consume_number
    literal = scanner.scan(/[-0-9.]+/)
    add_token(TokenType::NUMBER, literal: literal.to_f)
  end

  TOKEN_NULL = :null
  TOKEN_TRUE = :true
  TOKEN_FALSE = :false
  
  def consume_identifier
    literal = scanner.scan(/\w+/).to_sym

    case literal
    when TOKEN_NULL
      add_token(TokenType::NULL, literal: literal)
    when TOKEN_TRUE, TOKEN_FALSE
      add_token(TokenType::BOOLEAN, literal: literal)
    end
  end

  def add_token(type, literal: nil)
    lexeme = scanner.matched
    @tokens << Token.new(type, lexeme, literal)
  end
end
