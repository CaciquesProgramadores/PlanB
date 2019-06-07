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

def authenticate(account_data)
  LastWillFile::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  { account: LastWillFile::Account.first(username: account['username']),
    scope: AuthScope.new(contents['scope']) }
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.load File.read('app/db/seeds/accounts_seed.yml')
DATA[:inheritors] = YAML.safe_load File.read('app/db/seeds/inheritor_seeds.yml')
DATA[:notes] = YAML.safe_load File.read('app/db/seeds/notes_seeds.yml')

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('specs/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load(File.read('specs/fixtures/sso_account.yml'))

