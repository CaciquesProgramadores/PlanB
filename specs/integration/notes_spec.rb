# frozen_string_literal: true

require_relative '../spec_helper'
require 'pry'

describe 'Test Note Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = LastWillFile::Account.create(@account_data)
    @wrong_account = LastWillFile::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end


  describe 'Getting Notes' do
    describe 'Getting list of notes' do
      before do
        @account.add_owned_note(DATA[:notes][0])
        @account.add_owned_note(DATA[:notes][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/notes'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/notes'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end
   
    it 'HAPPY: should be able to get details of a single notes' do
      proj = @account.add_owned_note(DATA[:notes][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/notes/#{proj.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal proj.id
      _(result['attributes']['title']).must_equal proj.title
    end

    it 'SAD: should return error if unknown notes requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/notes/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get notes with wrong authorization' do
      proj = @account.add_owned_note(DATA[:notes][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/notes/#{proj.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_note(DATA[:notes][0])
      @account.add_owned_note(DATA[:notes][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/notes/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New notes' do
    before do
      @proj_data = DATA[:notes][0]
    end

    it 'HAPPY: should be able to create new notes' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/notes', @proj_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      proj = LastWillFile::Note.first

      _(created['id']).must_equal proj.id
      _(created['title']).must_equal @proj_data['title']
      _(created['description']).must_equal @proj_data['description']
    end

    it 'SAD: should not create new note without authorization' do
      post 'api/v1/notes', @proj_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create note with mass assignment' do
      bad_data = @proj_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/notes', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end

    it 'Happy: should able to update note with owner permission only' do
      updated = @account.add_owned_note(DATA[:notes][0])
      updated.title = "Updated title"
      updated.description = "Updated description."
      #binding.pry
      
      header 'AUTHORIZATION', auth_header(@account_data)
      put 'api/v1/notes', updated.to_json
      binding.pry
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0
    end

    it 'Happy: should able to delete note with owner permission only' do
      data = @account.add_owned_note(DATA[:notes][0])
      

      header 'AUTHORIZATION', auth_header(@account_data)
      delete 'api/v1/notes', (data.id).to_json
      binding.pry

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0
    end
  end
end