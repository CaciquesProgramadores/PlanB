# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Inheritor Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:notes].each do |note_data|
      LastWillFile::Note.create(note_data)
    end
  end

  it 'HAPPY: should be able to get list of all inheritors' do
    proj = LastWillFile::Note.first
    DATA[:inheritors].each do |doc|
      proj.add_inheritor(doc)
    end

    get "api/v1/notes/#{proj.id}/inheritors"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single inheritor' do
    doc_data = DATA[:inheritors][1]
    proj = LastWillFile::Note.first
    doc = proj.add_document(doc_data).save

    get "/api/v1/notes/#{proj.id}/inheritors/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal doc.id
    _(result['data']['attributes']['description']).must_equal doc_data['description']
  end

  it 'SAD: should return error if unknown inheritor requested' do
    proj = LastWillFile::Note.first
    get "/api/v1/notes/#{proj.id}/inheritors/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new inheritors' do
    proj = LastWillFile::Note.first
    doc_data = DATA[:inheritors][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/notes/#{proj.id}/inheritors",
         doc_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    doc = LastWillFile::Inheritor.first

    _(created['id']).must_equal doc.id
    _(created['description']).must_equal doc_data['description']
  end
end
