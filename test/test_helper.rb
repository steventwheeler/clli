$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'clli'
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

class Minitest::Test
  def self.test(name, &block)
    name = name.gsub(/[^a-zA-Z0-9_]+/, '_')
    define_method("test_#{name}".to_sym, &block)
  end

  def load_data(*paths)
    data = YAML.load_file(real_path(paths))
    data = deep_symbolize_keys(data)
    data.freeze
  end

  private

  def real_path(*paths)
    File.join([File.dirname(__FILE__)] + paths)
  end

  def deep_symbolize_keys(hash)
    hash.keys.each do |key|
      value = hash.delete(key)
      key = (key.to_sym rescue key) || key
      value = deep_symbolize_keys(value) if value.is_a?(Hash)
      hash[key] = value
    end
    hash
  end
end
