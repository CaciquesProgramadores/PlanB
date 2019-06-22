# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddExecutor service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      LastWillFile::Account.create(account_data)
    end

    note_data = DATA[:notes].first

    @owner_data = DATA[:accounts][0]
    @owner = LastWillFile::Account.all[0]
    @executor = LastWillFile::Account.all[1]
    @note = @owner.add_owned_note(note_data)
  end

  it 'HAPPY: should be able to add a executor to a note' do
    auth = authorization(@owner_data)

    LastWillFile::AddExecutor.call(
      auth:         auth,
      project:         @note,
      collab_email: @executor.email
    )

    _(@executor.notes.count).must_equal 1
    _(@executor.notes.first).must_equal @note
  end

  it 'BAD: should not add owner as a executor' do
    auth = LastWillFile::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    proc {
      LastWillFile::AddExecutor.call(
        auth:         auth,
        project:         @note,
        collab_email: @owner.email
      )
    }.must_raise LastWillFile::AddExecutor::ForbiddenError
  end
end
