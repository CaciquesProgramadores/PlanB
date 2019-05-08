# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Note Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting Notes' do
    it 'HAPPY: should be able to get list of all notes' do
      LastWillFile::Note.create(DATA[:notes][0]).save
      LastWillFile::Note.create(DATA[:notes][1]).save

      get 'api/v1/notes'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single note' do
      existing_proj = DATA[:notes][1]
      LastWillFile::Note.create(existing_proj).save
      id = LastWillFile::Note.first.id

      get "/api/v1/notes/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['description']).must_equal existing_proj['description']
    end

    it 'SAD: should return error if unknown note requested' do
      get '/api/v1/notes/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      LastWillFile::Note.create(description: 'New Note',  title: 'titulo 1')
      LastWillFile::Note.create(description: 'Newer Note', title: 'titulo 2')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Notes' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @notes_data = DATA[:notes][1]
    end

    it 'HAPPY: should be able to create new notes' do
      post 'api/v1/notes', @notes_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      proj = LastWillFile::Note.first

      _(created['id']).must_equal proj.id
      _(created['description']).must_equal @notes_data['description']
    end

    it 'SECURITY: should not create note with mass assignment' do
      bad_data = @notes_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/notes', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end

    it 'SECURITY: should secure sensitive attributes' do
      proj = DATA[:notes][1]
      LastWillFile::Note.create(proj).save
      store_note1 = LastWillFile::Note.first
      store_note2 = app.DB[:notes].first

      _(store_note1['description_secure']).wont_equal proj['description']
      _(store_note2['description_secure']).wont_equal proj['description']
    end
  end
end
