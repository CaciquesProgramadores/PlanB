# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Inheritor Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:notes].each do |note_data|
      LastWillFile::Note.create(note_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    doc_data = DATA[:inheritors][1]
    proj = LastWillFile::Note.first
    new_doc = proj.add_inheritor(doc_data)

    doc = LastWillFile::Inheritor.find(id: new_doc.id)
    _(doc.description).must_equal new_doc.description
    _(doc.relantionship).must_equal new_doc.relantionship
    _(doc.emails).must_equal new_doc.emails
    _(doc.phones).must_equal new_doc.phones
    _(doc.nickname).must_equal new_doc.nickname
    _(doc.pgp).must_equal new_doc.pgp
    _(doc.fullname).must_equal new_doc.fullname
  end
end