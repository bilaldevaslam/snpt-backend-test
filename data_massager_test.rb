# frozen_string_literal: true

require 'test/unit'
require './data_massager'

class DataMassagerTest < Test::Unit::TestCase
  # Test:01 remove empty array
  def test_empty_array
    object = stub_object.merge("hashtags": [])
    data_massager = DataMassager.new
    return_object = data_massager.sanitize(object)
    assert return_object.key?(:hashtags) ? false : true
  end

  # Test:02 remove '_id' field
  def test_id_field
    object = stub_object.merge("_id": {
                                 "$oid": '5aa104e0f20e84e6104ceccb'
                               })
    data_massager = DataMassager.new
    return_object = data_massager.sanitize(object)
    assert return_object.key?(:_id) ? false : true
  end

  # Test 03: passing all correct data
  def test_valid_data
    data_massager = DataMassager.new
    return_object = data_massager.sanitize(stub_object)
    assert return_object == stub_object
  end

  # Test 04: remove alphanumeric characters from bio field
  def test_alphanumeric_bio
    object = stub_object.merge("bio": 'Cafe 🍳 Bar 🍺 Events 🥂 Ringwood Golf Course 🌿')
    data_massager = DataMassager.new
    return_object = data_massager.sanitize(object)

    bio = return_object[:bio]
    assert bio.match(/[^\p{Alnum}\p{Space}+!+:]/) ? false : true
  end

  # Test 05: check new file creation
  def test_new_file
    data_massager = DataMassager.new
    data_massager.parse('./testing-user.json')
    assert File.exist?('file-1.json') ? true : false
  end

  # Test 06: verify correctness of data in newly created split file
  def test_new_file_data
    prase_data = DataMassager.new
    prase_data.parse('./testing-user.json')

    result = true

    file_stream = File.open('./file-1.json', 'r')
    streamer = Json::Streamer.parser(file_io: file_stream)
    streamer.get(nesting_level: 1, symbolize_keys: true) do |object|
      if object.key?('_id') || (object[:bio] != '' && !object[:bio].match(/[^\p{Alnum}]/))
        result = false
        break
      end
    end

    assert result
  end

  def stub_object
    @stub_object ||= {
      "id": '997634548',
      "type": 'add',
      "username": 'said_buenrostro',
      "bio": '',
      "followed_by": 653,
      "mentions": %w[
        tena2099
        berlinphil
        insurgentebrew
        cervezapacheco
        cervezafauna
        casacardinal
        moderntimesbeer
        eviltwinbrewing
        mikkellerbeer
        brewdogofficial
      ],
      "hashtags": %w[
        moderntimesbeer
        eviltwinbrewing
        mikkellerbeer
        brewdogofficial
      ]
    }
  end
end
