# frozen_string_literal: true

module LastWillFile
  # Service object to create a new note for an owner
  class CreateNoteForOwner
    def self.call(owner_id:, note_data:)
      Account.first(id: owner_id)
             .add_owned_note(note_data)
    end
  end
end
