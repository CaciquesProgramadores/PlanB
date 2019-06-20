# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Add a Authorise to another owner's existing note
  class AddAuthorise
    # Error for owner cannot be Authorise
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as Authorise'
      end
    end

    def self.call(auth:, project:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = AuthoriseRequestPolicy.new(project, auth[:account], invitee, auth[:scope])
      
      raise ForbiddenError unless policy.can_invite?

      project.add_authorise(invitee)
      invitee
    end
  end
end
