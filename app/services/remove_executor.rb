# frozen_string_literal: true

module LastWillFile
  # Add a executor to another owner's existing note
  class RemoveExecutor
    # Error for owner cannot be executor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(req_username:, collab_email:, note_id:)
      account = Account.first(username: req_username)
      note = Note.first(id: note_id)
      executor = Account.first(email: collab_email)

      policy = ExecutorRequestPolicy.new(note, account, executor)
      raise ForbiddenError unless policy.can_remove?

      note.remove_executor(executor)
      executor
    end
  end
end
