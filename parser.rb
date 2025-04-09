require_relative "nodes/array"
require_relative "nodes/json_expression"
require_relative "nodes/pair"
require_relative "nodes/literal"
require_relative "token"
require_relative "token_type"

class Parser
  attr_accessor :tokens, :current_index

  def initialize(tokens)
    @tokens = tokens
    @current_index = 0
  end

  def parse
    consume_json_expression
  end

  def consume_json_expression
    pairs = []

    if (consume_tokens_if_match(TokenType::LEFT_BRACKET))
      while is_json_expression_continuing?
        pairs << consume_pair

        if !match_without_consume(TokenType::COMMA) && is_json_expression_continuing?
          binding.irb
          raise "Expect COMMA!"
        else
          consume_tokens_if_match(TokenType::COMMA)
        end

      end

      consume_tokens_if_match(TokenType::RIGHT_BRACKET)
    end

    Node::JsonExpression.new(pairs)
  end

  def consume_pair
    key = consume_literal
    unless key.is_a?(Node::String)
      raise "Expect Key String"
    end

    unless consume_tokens_if_match(TokenType::COLON)
      raise "Expect COLON"
    end

    value = consume_json_value
    Node::Pair.new(key, value)
  end

  def consume_json_value
    if match_without_consume(TokenType::LEFT_BRACKET)
      return consume_json_expression
    end

    if match_without_consume([TokenType::STRING, TokenType::NUMBER])
      return consume_literal
    end

    raise "Expression Expected!, it is #{current_token.type}, #{current_token.literal}"
  end

  def consume_array
  end

  def consume_literal
    if consume_tokens_if_match(TokenType::STRING)
      value = previous_token.literal
      return Node::String.new(value)
    end

    if consume_tokens_if_match(TokenType::NUMBER)
      value = previous_token.literal
      return Node::Number.new(value)
    end

    binding.irb
    raise "Expect literal! it is #{current_token.type}, #{current_token.literal}"
  end

  private

  def match_without_consume(token_types)
    token_types = token_types.is_a?(Array) ? token_types : [token_types]
    token_types.each do |token_type|
      if current_token.type == token_type
        return true
      end
    end

    return false
  end

  def consume_tokens_if_match(token_types)
    token_types = token_types.is_a?(Array) ? token_types : [token_types]
    token_types.each do |token_type|
      if current_token.type == token_type
        @current_index += 1
        return true
      end
    end

    return false
  end

  def previous_token
    tokens[current_index - 1]
  end

  def current_token
    tokens[current_index]
  end

  def next_token
    tokens[current_index + 1]
  end

  def is_json_expression_continuing?
    !next_token.nil? && !match_without_consume(TokenType::RIGHT_BRACKET)
  end
end

# JSON BNF
# <jsonExpr>  ::= "{" <pair> ("," <pair>)* "}"
# <pair>      ::= STRING ":" <jsonValue>
# <jsonValue> ::= <array> | <literal> | <jsonExpr>
# <array>     ::= "[" <jsonValue> ("," <jsonValue>)* "]"
# <literal>   ::= STRING | NUMBER
