# frozen_string_literal: true

module LastWillFile
  # Service object to create a new note for an owner
  class CreateNoteForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more inheritors'
      end
    end

    def self.call(auth:, note_data:)
      raise ForbiddenError unless auth[:scope].can_write?('notes')

      auth[:account].add_owned_note(note_data)
      #Account.first(id: owner_id)
             #.add_owned_note(note_data)
    end
  end
end
