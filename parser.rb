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
          raise "Expect COMMA!, current_token: #{current_token.type}, #{current_token.literal}"
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

    if match_without_consume(TokenType::LEFT_ARRAY)
      return consume_array
    end

    if match_without_consume([TokenType::STRING, TokenType::NUMBER, TokenType::NULL, TokenType::BOOLEAN])
      return consume_literal
    end

    raise "Expression Expected!, it is #{current_token.type}, #{current_token.literal}"
  end

  def consume_array
    consume_tokens_if_match([TokenType::LEFT_ARRAY])
    elements = []

    while !match_without_consume([TokenType::RIGHT_ARRAY])
      elements << consume_json_value

      if !match_without_consume([TokenType::COMMA]) && !next_token.type == TokenType::RIGHT_ARRAY
        raise "Expect COMMA between array elements!"
      else
        consume_tokens_if_match([TokenType::COMMA])
      end
    end

    consume_tokens_if_match([TokenType::RIGHT_ARRAY])

    Node::Array.new(elements)
  end

  def consume_literal
    if consume_tokens_if_match([TokenType::STRING, TokenType::NUMBER, TokenType::NULL, TokenType::BOOLEAN])
      value = previous_token.literal
      node_class = previous_token.type.downcase.capitalize

      return Node::Literal.const_get("Node::#{node_class}").new(value)
    end

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
