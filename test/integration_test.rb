require 'minitest/autorun'
require 'json'
require_relative '../scanner'
require_relative '../parser'

class IntegrationTest < Minitest::Test
  def parse_json(json)
    tokens = Scanner.new(json).scan_tokens
    ast = Parser.new(tokens).parse
    ast.to_ruby_hash
  end

  def test_matches_json_parse_simple
    json = '{"name": "John", "age": 30}'
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  def test_matches_json_parse_array
    json = '{"numbers": [1, 2, 3], "strings": ["a", "b", "c"]}'
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  def test_matches_json_parse_nested
    json = '{"user": {"name": "John", "address": {"city": "Tokyo", "country": "Japan"}}}'
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  def test_matches_json_parse_complex
    json = '{
      "id": 123,
      "name": "Product",
      "price": 99.99,
      "tags": ["new", "sale"],
      "stock": {
        "warehouse1": 100,
        "warehouse2": 50
      },
      "active": true,
      "description": null
    }'
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  def test_matches_json_parse_large_array
    elements = (1..100).map { |i| {"id": i, "value": "item#{i}"} }
    json = JSON.generate({"items": elements})
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  def test_matches_json_parse_all_types
    json = '{
      "string": "Hello",
      "number": 42,
      "float": 3.14,
      "array": [1, 2, 3],
      "object": {"key": "value"},
      "true": true,
      "false": false,
      "null": null
    }'
    expected = JSON.parse(json)
    actual = parse_json(json)
    assert_equal expected, actual
  end

  # def test_error_handling_matches
  #   invalid_jsons = [
  #     '{',                    # 未完成のオブジェクト
  #     '{"key": }',            # 値なし
  #     '{"key": "value",}',    # 末尾のカンマ
  #     '{"key": undefined}',   # 不正な値
  #     '[1, 2, 3',            # 未完成の配列
  #   ]

  #   invalid_jsons.each do |invalid_json|
  #     assert_raises(RuntimeError) { parse_json(invalid_json) }
  #     assert_raises(JSON::ParserError) { JSON.parse(invalid_json) }
  #   end
  # end
end
