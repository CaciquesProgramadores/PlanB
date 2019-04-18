# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
app.DB[:notes].delete
app.DB[:inheritors].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:inheritors] = YAML.safe_load File.read('app/db/seeds/inheritor_seeds.yml')
DATA[:notes] = YAML.safe_load File.read('app/db/seeds/notes_seeds.yml')
