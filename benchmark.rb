require 'benchmark/ips'
require 'json'
require_relative 'scanner'
require_relative 'parser'

# テストケース
json_samples = {
  "simple" => '{"name": "John", "age": 30}',
  "array" => '{"items": [1,2,3,4,5]}',
  "nested" => '{"user": {"name": "John", "address": {"city": "Tokyo"}}}',
  "large_array" => "[" + (1..1000).map(&:to_s).join(",") + "]",
  "complex" => '{"users": [{"id": 1, "name": "John"}, {"id": 2, "name": "Jane"}]}'
}

def scan_only(json)
  Scanner.new(json).scan_tokens
end

def parse_only(tokens)
  Parser.new(tokens).parse
end

def to_ruby_only(ast)
  ast.to_ruby_hash
end

def parse_with_custom(json)
  tokens = Scanner.new(json).scan_tokens
  ast = Parser.new(tokens).parse
  ast.to_ruby_hash
end

puts "Performance Analysis for each step:"
puts "-" * 50

json_samples.each do |name, json|
  puts "\nTesting #{name} JSON:"
  tokens = nil
  ast = nil
  
  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)
    
    x.report("1. Scan phase") { scan_only(json) }
    x.report("2. Parse phase") { 
      tokens ||= scan_only(json)
      parse_only(tokens)
    }
    x.report("3. To Ruby phase") {
      tokens ||= scan_only(json)
      ast ||= parse_only(tokens)
      to_ruby_only(ast)
    }
    x.report("All phases") { parse_with_custom(json) }
    x.report("JSON.parse") { JSON.parse(json) }
    
    x.compare!
  end
end
