require 'benchmark/ips'
require 'json'
require_relative 'ruby_json'
require_relative 'parsers/simple_parser'

# テストケース
json_samples = {
  "simple" => '{"name": "John", "age": 30}',
  "array" => '{"items": [1,2,3,4,5]}',
  "nested" => '{"user": {"name": "John", "address": {"city": "Tokyo"}}}',
  "large_array" => "[" + (1..1000).map(&:to_s).join(",") + "]",
  "complex" => '{"users": [{"id": 1, "name": "John"}, {"id": 2, "name": "Jane"}]}'
}

# ウォームアップ
json_samples.each do |_, json|
  RubyJSON.parse(json)
  RubyJSON.parse(json, scanner_class: ScannerWithStringScanner)
  JSON.parse(json)
end

# ベンチマーク実行
puts "Benchmarking JSON parsing (iterations per second):"
puts "-" * 50

json_samples.each do |name, json|
  puts "\nTesting #{name} JSON:"
  Benchmark.ips do |x|
    x.config(time: 5, warmup: 2)

    # それぞれのJSONパーサーで計測
    x.report("RubyJSON.parse") { RubyJSON.parse(json) }
    x.report("RubyJSON.parse (with StringScanner)") { RubyJSON.parse(json, scanner_class: ScannerWithStringScanner) }
    x.report("JSON.parse") { JSON.parse(json) }

    # 比較のため、最速のパーサーも報告
    x.compare!
  end
end
