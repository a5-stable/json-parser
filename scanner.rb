require_relative "token_type"
require_relative "token"

class Scanner
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
    when " "
    when '"'
      consume_string
    else
      if is_number?(current_token)
        consume_number
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
    current_letter = fetch_current_letter

    while is_number?(current_letter)
      current_letter = fetch_current_letter
      @current_index += 1
    end
    literal = fetch_substring(start_index, current_index)
    add_token(TokenType::NUMBER, literal: literal.to_i)
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
    str =~ /^[0-9]+$/ ? true : false
  end

  def is_end
    current_index >= json_string.size
  end
end

# {
#   "id": "XXX"
# }
