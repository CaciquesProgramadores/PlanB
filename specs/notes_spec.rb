# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Note Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

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
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['description']).must_equal existing_proj['description']
  end

  it 'SAD: should return error if unknown note requested' do
    get '/api/v1/notes/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new notes' do
    existing_proj = DATA[:notes][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/notes', existing_proj.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    proj = LastWillFile::Note.first

    _(created['id']).must_equal proj.id
    _(created['description']).must_equal existing_proj['description']
  end
end
