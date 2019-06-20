# frozen_string_literal: true

module LastWillFile
    # Add a collaborator to another owner's existing project
    class AddExecutorToNote
      # Error for owner cannot be collaborator
      class OwnerNotExecutorError < StandardError
        def initialize(msg = nil)
          @credentials = msg
        end
  
        def message
          'Owner cannot be collaborator of project'
        end
      end
  
      def self.call(email:, note_id:)
        executor = Account.first(email: email)
        note = Note.first(id: note_id)
        raise(OwnerNotExecutorError) if note.owner.id == executor.id
  
        note.add_executor(executor)
        executor
      end
    end
  end
  