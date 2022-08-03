# frozen_string_literal: true

# https://github.com/thisismydesign/json-streamer
# stream based json parsing with nested level support
# using it to deal with array of hashes
require 'json/streamer'
require 'json'

class DataMassager
  CHUNK_SIZE = 100

  def initialize
    @file_counter = 0
    @json_array = []
  end

  def parse(path)
    file_stream = File.open(path, 'r')
    streamer = Json::Streamer.parser(file_io: file_stream)

    streamer.get(nesting_level: 1, symbolize_keys: true) do |object|
      object = sanitize(object)
      if @json_array.count == CHUNK_SIZE
        create_file
        @json_array = []
      else
        @json_array.append(object)
      end
    end

    create_file # to dump the remaining objects
  end

  def create_file
    @file_counter += 1
    json_export("./file-#{@file_counter}.json", @json_array)
  end

  def json_export(file_path, data)
    File.open(file_path, 'w') do |f|
      f.puts JSON.pretty_generate(data)
    end
  end

  def sanitize(object)
    # Remove empty arrays and '_id' key from json object
    object.reject! { |key, value| value if (value.is_a?(Array) && value.empty?) || key == '_id'.to_sym }

    # Update the bio to contain only alpha-numeric characters
    object.update(bio: object[:bio].gsub(/[^\p{Alnum}\p{Space}+!+:]/, ''))
  end
end

DataMassager.new.parse('./1000-users.json')
