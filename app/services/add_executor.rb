# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Add a executor to another owner's existing note
  class AddExecutor
    # Error for owner cannot be executor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as executor'
      end
    end

    def self.call(auth:, project:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = ExecutorRequestPolicy.new(project, auth[:account], invitee, auth[:scope])
      
      raise ForbiddenError unless policy.can_invite?

      project.add_executor(invitee)
      invitee
    end
  end
end
