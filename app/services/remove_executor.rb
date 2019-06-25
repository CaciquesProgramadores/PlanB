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

    def self.call(auth:, collab_email:, project_id:)
      account = Account.first(username: project_id)
      note = Note.first(id: project_id)
      executor = Account.first(email: collab_email)

      policy = ExecutorRequestPolicy.new(auth[:account], collab_email, auth[:scope])
      raise ForbiddenError unless policy.can_remove?

      note.remove_executor(executor)
      executor
    end
  end
end
