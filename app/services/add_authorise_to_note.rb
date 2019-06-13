# frozen_string_literal: true

module LastWillFile
    # Add a collaborator to another owner's existing project
    class AddAuthoriseToNote
      # Error for owner cannot be collaborator
      class OwnerNotAuthoriseError < StandardError
        def initialize(msg = nil)
          @credentials = msg
        end
  
        def message
          'Owner cannot be collaborator of project'
        end
      end
  
      def self.call(email:, note_id:)
        authorise = Account.first(email: email)
        note = Note.first(id: note_id)
        raise(OwnerNotAuthoriseError) if note.owner.id == authorise.id
  
        note.add_authorise(authorise)
        authorise
      end
    end
  end
  