# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'

require_relative '../app/models/note'
require_relative '../app/models/inheritor'

require_relative '../app/models/document'

def app
  LastWillFile::Api
end

DATA_doc = YAML.safe_load File.read('app/db/seeds/document_seeds.yml')
DATA_inh = YAML.safe_load File.read('app/db/seeds/inheritor_seeds.yml')
DATA_note = YAML.safe_load File.read('app/db/seeds/notes_seeds.yml')

describe 'Test LastWillFile Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob('app/db/store/*.txt').each { |filename| FileUtils.rm(filename) }
    Dir.glob('app/db/store/inheritors/*.txt').each { |filename| FileUtils.rm(filename) }
    Dir.glob('app/db/store/notes/*.txt').each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle documents' do
    it 'HAPPY: should be able to get list of all documents' do
      LastWillFile::Document.new(DATA_doc[0]).save
      LastWillFile::Document.new(DATA_doc[1]).save

      get 'api/v1/documents'
      result = JSON.parse last_response.body
      _(result['document_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single document' do
      LastWillFile::Document.new(DATA_doc[1]).save
      id = Dir.glob('app/db/store/*.txt').first.split(%r{[/\.]})[3]

      get "/api/v1/documents/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown document requested' do
      get '/api/v1/documents/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new documents' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/documents', DATA_doc[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end

  describe 'Handle inheritors' do
    it 'HAPPY: should be able to get list of all inheritors' do
      LastWillFile::Inheritor.new(DATA_inh[0]).save
      LastWillFile::Inheritor.new(DATA_inh[1]).save

      get 'api/v1/inheritors'
      result = JSON.parse last_response.body
      _(result['inheritor_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single inheritor' do
      LastWillFile::Inheritor.new(DATA_inh[1]).save
      id = Dir.glob('app/db/store/inheritors/*.txt').first.split(%r{[/\.]})[4]

      get "/api/v1/inheritors/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown inheritor requested' do
      get '/api/v1/inheritors/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new inheritors' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/inheritors', DATA_inh[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end

  describe 'Handle notes' do
    it 'HAPPY: should be able to get list of all notes' do
      LastWillFile::Note.new(DATA_note[0]).save
      LastWillFile::Note.new(DATA_note[1]).save

      get 'api/v1/notes'
      result = JSON.parse last_response.body
      _(result['note_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single note' do
      LastWillFile::Note.new(DATA_note[1]).save
      id = Dir.glob('app/db/store/notes/*.txt').first.split(%r{[/\.]})[4]

      get "/api/v1/notes/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown note requested' do
      get '/api/v1/notes/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new notes' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/notes', DATA_note[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
