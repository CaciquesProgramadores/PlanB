# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  LastWillFile::Inheritor.map(&:destroy)
  LastWillFile::Note.map(&:destroy)
  LastWillFile::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = LastWillFile::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.load File.read('app/db/seeds/accounts_seed.yml')
DATA[:inheritors] = YAML.safe_load File.read('app/db/seeds/inheritor_seeds.yml')
DATA[:notes] = YAML.safe_load File.read('app/db/seeds/notes_seeds.yml')
