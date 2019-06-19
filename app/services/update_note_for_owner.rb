# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Service object to create a new note for an owner
  class UpdateNoteForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more inheritors'
      end
    end

    def self.call(auth:, note_data:)
      
      raise ForbiddenError unless auth[:scope].can_write?('notes')

      note = Note.find(id: note_data['id'].to_i)
      no_key = note_data.reject{|k,v| k == "id"}

      note.update(no_key)
    end
  end
end
