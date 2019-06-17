# frozen_string_literal: true

module LastWillFile
  # Add a Authorise to another owner's existing note
  class AddAuthorise
    # Error for owner cannot be Authorise
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as Authorise'
      end
    end

    def self.call(account:, note:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = AuthoriseRequestPolicy.new(
        note, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      note.add_authorise(invitee)
      invitee
    end
  end
end
