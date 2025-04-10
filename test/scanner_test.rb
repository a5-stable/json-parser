require 'minitest/autorun'
require_relative '../scanner'
require_relative '../token_type'

class ScannerTest < Minitest::Test
  def test_empty_object
    scanner = Scanner.new("{}")
    tokens = scanner.scan_tokens
    
    assert_equal 2, tokens.size
    assert_equal TokenType::LEFT_BRACKET, tokens[0].type
    assert_equal TokenType::RIGHT_BRACKET, tokens[1].type
  end

  def test_simple_string
    scanner = Scanner.new('{"name": "John"}')
    tokens = scanner.scan_tokens
    
    expected_types = [
      TokenType::LEFT_BRACKET,
      TokenType::STRING,
      TokenType::COLON,
      TokenType::STRING,
      TokenType::RIGHT_BRACKET
    ]
    
    assert_equal expected_types.size, tokens.size
    expected_types.each_with_index do |type, i|
      assert_equal type, tokens[i].type
    end
    
    assert_equal "name", tokens[1].literal
    assert_equal "John", tokens[3].literal
  end

  def test_numbers
    scanner = Scanner.new('{"age": 30, "price": 1.5}')
    tokens = scanner.scan_tokens
    
    assert_equal 30, tokens[3].literal
    assert_equal 1.5, tokens[7].literal
  end

  def test_array
    scanner = Scanner.new('{"items": [1, 2, 3]}')
    tokens = scanner.scan_tokens
    
    expected_types = [
      TokenType::LEFT_BRACKET,
      TokenType::STRING,
      TokenType::COLON,
      TokenType::LEFT_ARRAY,
      TokenType::NUMBER,
      TokenType::COMMA,
      TokenType::NUMBER,
      TokenType::COMMA,
      TokenType::NUMBER,
      TokenType::RIGHT_ARRAY,
      TokenType::RIGHT_BRACKET
    ]
    
    assert_equal expected_types.size, tokens.size
    expected_types.each_with_index do |type, i|
      assert_equal type, tokens[i].type
    end
  end

  def test_boolean_and_null
    scanner = Scanner.new('{"active": true, "deleted": false, "data": null}')
    tokens = scanner.scan_tokens
    
    assert_equal "true", tokens[3].literal
    assert_equal "false", tokens[7].literal
    assert_equal "null", tokens[11].literal
  end

  def test_nested_structure
    scanner = Scanner.new('{"user": {"name": "John", "age": 30}}')
    tokens = scanner.scan_tokens
    
    expected_types = [
      TokenType::LEFT_BRACKET,
      TokenType::STRING,
      TokenType::COLON,
      TokenType::LEFT_BRACKET,
      TokenType::STRING,
      TokenType::COLON,
      TokenType::STRING,
      TokenType::COMMA,
      TokenType::STRING,
      TokenType::COLON,
      TokenType::NUMBER,
      TokenType::RIGHT_BRACKET,
      TokenType::RIGHT_BRACKET
    ]
    
    assert_equal expected_types.size, tokens.size
    expected_types.each_with_index do |type, i|
      assert_equal type, tokens[i].type
    end
  end

  def test_error_unfinished_string
    assert_raises(RuntimeError) do
      Scanner.new('{"name": "John').scan_tokens
    end
  end
end
