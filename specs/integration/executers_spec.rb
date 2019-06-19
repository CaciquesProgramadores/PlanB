# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Executers Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][2]

    @account = LastWillFile::Account.create(@account_data)
    @another_account = LastWillFile::Account.create(@another_account_data)
    @wrong_account = LastWillFile::Account.create(@wrong_account_data)

    @proj = @account.add_owned_note(DATA[:notes][0])

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding executers to a note' do
    it 'HAPPY: should add a valid executer' do
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/notes/#{@proj.id}/authorises", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username
    end

    it 'SAD AUTHORIZATION: should not add collaborator without authorization' do
      req_data = { email: @another_account.email }

      put "api/v1/notes/#{@proj.id}/authorises", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add an invalid authoriser' do
      req_data = { email: @account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/notes/#{@proj.id}/authorises", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end
  end

  describe 'Removing collaborators from a project' do
    it 'HAPPY: should remove with proper authorization' do
      @proj.add_authorise(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/notes/#{@proj.id}/authorises", req_data.to_json

      _(last_response.status).must_equal 200
    end

    it 'SAD AUTHORIZATION: should not remove without authorization' do
      @proj.add_authorise(@another_account)
      req_data = { email: @another_account.email }

      delete "api/v1/notes/#{@proj.id}/authorises", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD AUTHORIZATION: should not remove invalid collaborator' do
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/notes/#{@proj.id}/authorises", req_data.to_json

      _(last_response.status).must_equal 403
      
    end
  end
end
