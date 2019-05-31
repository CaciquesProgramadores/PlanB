# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Inheritor Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = LastWillFile::Account.create(@account_data)
    @account.add_owned_note(DATA[:notes][0])
    @account.add_owned_note(DATA[:notes][1])
    LastWillFile::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single inheritor' do
    it 'HAPPY: should be able to get details of a single inheritor' do
      doc_data = DATA[:inheritors][0]
      proj = @account.notes.first
      doc = proj.add_inheritor(doc_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/inheritors/#{doc.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal doc.id
      _(result['attributes']['fullname']).must_equal doc_data['fullname']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      doc_data = DATA[:inheritors][1]
      proj = LastWillFile::Note.first
      doc = proj.add_inheritor(doc_data)

      get "/api/v1/inheritors/#{doc.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      doc_data = DATA[:inheritors][0]
      proj = @account.notes.first
      doc = proj.add_inheritor(doc_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/inheritors/#{doc.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if inheritor does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/inheritors/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Inheritor' do
    before do
      @proj = LastWillFile::Note.first
      @doc_data = DATA[:inheritors][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/notes/#{@proj.id}/inheritors", @doc_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      doc = LastWillFile::Inheritor.first

      _(created['id']).must_equal doc.id
      _(created['fullname']).must_equal @doc_data['fullname']
      _(created['relantionship']).must_equal @doc_data['relantionship']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/notes/#{@proj.id}/inheritors", @doc_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/notes/#{@proj.id}/inheritors", @doc_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/notes/#{@proj.id}/inheritors", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
