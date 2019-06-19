# frozen_string_literal: true

require'pry'

module LastWillFile
    # Add a authorise to another owner's existing note
    class RemoveNote
      # Error for owner cannot be authorise
      class ForbiddenError < StandardError
        def message
          'You are not allowed to remove that note'
        end
      end
  
      def self.call(req_username:, note_id:)
        account = Account.first(username: req_username)
        note = Note.first(id: note_id)
        
        #policy = NotePolicy.new(note, account)
        
        #raise ForbiddenError unless policy.can_remove_notes?
  
        note.destroy
        
      end
    end
  end
  