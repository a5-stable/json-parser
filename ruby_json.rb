require_relative "scanners/simple_scanner"
require_relative "parsers/simple_parser"
require_relative "scanners/scanner_with_string_scanner"

class RubyJSON
  def self.parse(json_string, scanner_class: SimpleScanner, parser_class: SimpleParser)
    tokens = scanner_class.new(json_string).scan_tokens
    parser_class.new(tokens).parse.to_ruby_hash
  end
end
