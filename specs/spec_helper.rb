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

<<<<<<< HEAD
def authenticate(account_data)
  LastWillFile::AuthenticateAccount.call(
=======
=begin
def auth_header(account_data)
  auth = LastWillFile::AuthenticateAccount.call(
>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9
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
<<<<<<< HEAD
=======
=end
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
DATA[:inheritors] = YAML.load File.read('app/db/seeds/inheritor_seeds.yml')
DATA[:notes] = YAML.load File.read('app/db/seeds/notes_seeds.yml')
DATA[:owners] = YAML.load File.read('app/db/seeds/owners_notes.yml')
>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('specs/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
<<<<<<< HEAD
SSO_ACCOUNT = YAML.load(File.read('specs/fixtures/sso_account.yml'))

=======
SSO_ACCOUNT = YAML.load(File.read('specs/fixtures/sso_account.yml'))
>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9
