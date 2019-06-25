# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Existence Handling' do
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

  describe 'Getting a single existence' do
    it 'HAPPY: should be able to get details of a single existences' do
      doc_data = DATA[:existences][0]

      proj = @account.existences.first
      doc = proj.add_existence(doc_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/existences"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal doc.id
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      doc_data = DATA[:existences][1]
      proj = LastWillFile::Account.first
      doc = proj.add_existence(doc_data)

      get "/api/v1/existences"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      doc_data = DATA[:existences][0]
      proj = @account.existences.first
      doc = proj.add_existence(doc_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/existences"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end
  end
end
