require 'minitest/autorun'
require_relative '../scanner'
require_relative '../parser'
require_relative '../token_type'

class ParserTest < Minitest::Test
  def setup
    @scanner = Scanner.new("")  # 各テストで上書き
  end

  def parse(json)
    @scanner = Scanner.new(json)
    tokens = @scanner.scan_tokens
    parser = Parser.new(tokens)
    parser.parse
  end

  def test_empty_object
    ast = parse("{}")
    assert_instance_of Node::JsonExpression, ast
    assert_empty ast.pairs
  end

  def test_simple_pair
    ast = parse('{"name": "John"}')
    assert_equal 1, ast.pairs.size
    
    pair = ast.pairs.first
    assert_equal "name", pair.key.value
    assert_equal "John", pair.value.value
  end

  def test_multiple_pairs
    ast = parse('{"name": "John", "age": 30}')
    assert_equal 2, ast.pairs.size
    
    assert_equal "name", ast.pairs[0].key.value
    assert_equal "John", ast.pairs[0].value.value
    assert_equal "age", ast.pairs[1].key.value
    assert_equal 30, ast.pairs[1].value.value
  end

  def test_nested_object
    ast = parse('{"user": {"name": "John", "age": 30}}')
    
    user_value = ast.pairs.first.value
    assert_instance_of Node::JsonExpression, user_value
    assert_equal 2, user_value.pairs.size
    
    assert_equal "name", user_value.pairs[0].key.value
    assert_equal "John", user_value.pairs[0].value.value
    assert_equal "age", user_value.pairs[1].key.value
    assert_equal 30, user_value.pairs[1].value.value
  end

  def test_array
    ast = parse('{"numbers": [1, 2, 3]}')
    
    array = ast.pairs.first.value
    assert_instance_of Node::Array, array
    assert_equal 3, array.elements.size
    
    assert_equal 1, array.elements[0].value
    assert_equal 2, array.elements[1].value
    assert_equal 3, array.elements[2].value
  end

  def test_complex_structure
    ast = parse('{"users": [{"id": 1, "name": "John"}, {"id": 2, "name": "Jane"}]}')
    
    users = ast.pairs.first.value
    assert_instance_of Node::Array, users
    assert_equal 2, users.elements.size
    
    user1 = users.elements[0]
    assert_equal 1, user1.pairs[0].value.value
    assert_equal "John", user1.pairs[1].value.value
    
    user2 = users.elements[1]
    assert_equal 2, user2.pairs[0].value.value
    assert_equal "Jane", user2.pairs[1].value.value
  end

  def test_literals
    ast = parse('{"string": "text", "number": 42, "float": 3.14, "bool": true, "nil": null}')
    
    values = ast.pairs.map(&:value)
    assert_equal "text", values[0].value
    assert_equal 42, values[1].value
    assert_equal 3.14, values[2].value
    assert_equal "true", values[3].value
    assert_equal "null", values[4].value
  end

  def test_error_invalid_json
    assert_raises(RuntimeError) { parse('{') }
    assert_raises(RuntimeError) { parse('{"key": }') }
    assert_raises(RuntimeError) { parse('{"key": "value",}') }
  end
end
