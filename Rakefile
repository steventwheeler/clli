require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yaml/store'
require 'csv'
require 'clli'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

namespace :generate do
  task :city_cache do
    data = {}
    CSV.foreach(input_file) do |row|
      prefix, city, state = row
      prefix = prefix.strip
      city = normalize_city(city)
      state = state.strip
      next if city.nil? || city.empty?
      next if city == 'Not Available'
      next unless /[A-Z]{2}/ =~ state
      next unless /(?<place>[A-Z\s]{4})(?<region>[A-Z]{2})/ =~ prefix
      place = place.strip
      region = region.strip
      data[region] ||= {}
      data[region][place] = {
        'city' => city,
        'state' => state
      }
    end

    output_file = CLLI::YAMLData.real_path(%w(clli data cities.yml))
    File.truncate(output_file, 0) if File.exist?(output_file)

    store = YAML::Store.new(output_file)
    store.transaction do
      data.each do |region, place_data|
        store[region] = place_data
      end
    end
  end
end

def input_file
  file = ENV['file']

  if file.nil?
    puts 'Please specify the file to import.'
    exit 1
  end
  unless File.exist?(file)
    puts "File #{file} does not exist."
    exit 1
  end
  file
end

def normalize_city(city)
  city.strip!
  city.downcase!
  city.gsub!('so.', 'south ')
  city.gsub!(/\s*(\(.*?\))/, ' \1')
  city.gsub!(/\(\s*(.*?)\s*\)/, '(\1)')
  city.gsub!(/\s+/, ' ')
  city.gsub!(/(\w+(?:'s)?)/, &:capitalize)
  city
end
