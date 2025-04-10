require_relative "../token_type"
require_relative "../token"

class SimpleScanner
  include TokenType
  attr_accessor :json_string, :tokens, :current_index, :start_index

  def initialize(json_string)
    @json_string = json_string
    @tokens = []
    @start_index = 0
    @current_index = 0
  end

  def scan_tokens

    while !is_end
      @start_index = current_index
      scan_token
    end

    tokens
  end

  def scan_token
    current_token = fetch_current_letter
    @current_index += 1

    case current_token
    when "{"
      add_token(TokenType::LEFT_BRACKET)
    when "}"
      add_token(TokenType::RIGHT_BRACKET)
    when ":"
      add_token(TokenType::COLON)
    when ","
      add_token(TokenType::COMMA)
    when "["
      add_token(TokenType::LEFT_ARRAY)
    when "]"
      add_token(TokenType::RIGHT_ARRAY)
    when " "
    when '"'
      consume_string
    else
      if is_number?(current_token)
        consume_number
      else
        consume_identifier
      end
    end
  end

  private

  def consume_string
    literal = ''
    current_letter = fetch_current_letter

    while current_letter != '"'
      if (is_end)
        raise "unfinished string literal"
      end
      current_letter = fetch_current_letter
      literal += current_letter
      @current_index += 1

      current_letter = fetch_current_letter
    end

    # consume last double quotation
    @current_index += 1

    add_token(TokenType::STRING, literal: literal)
  end

  def consume_number
    if fetch_current_letter == '-'
      @current_index += 1
    end

    while is_number?(fetch_current_letter)
      @current_index += 1
    end

    if fetch_current_letter == '.'
      @current_index += 1
      
      while is_number?(fetch_current_letter)
        @current_index += 1
      end
    end

    literal = fetch_substring(start_index, current_index)
    add_token(TokenType::NUMBER, literal: literal.to_f)
  end

  TOKEN_NULL = :null
  TOKEN_TRUE = :true
  TOKEN_FALSE = :false
  def consume_identifier
    while is_alphabet?(fetch_current_letter)
      @current_index += 1
    end

    literal = fetch_substring(start_index, current_index).to_sym

    case literal
    when TOKEN_NULL_STRING
      add_token(TokenType::NULL, literal: literal)
    when TOKEN_TRUE_STRING, TOKEN_FALSE_STRING
      add_token(TokenType::BOOLEAN, literal: literal)
    end
  end

  def add_token(type, literal: nil)
    lexeme = fetch_substring(start_index, current_index)
    @tokens << Token.new(type, lexeme, literal)
  end

  def fetch_current_letter
    json_string[current_index]
  end

  def fetch_substring(from, to)
    json_string[from..to - 1]
  end

  def is_number?(str)
    str =~ /^[-0-9.]$/ ? true : false
  end

  def is_alphabet?(str)
    str =~ /\A[a-zA-Z]+\z/
  end

  def is_end
    current_index >= json_string.size
  end
end

# {
#   "id": "XXX"
# }
