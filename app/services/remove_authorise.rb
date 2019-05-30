# frozen_string_literal: true

module LastWillFile
  # Add a authorise to another owner's existing note
  class RemoveAuthorise
    # Error for owner cannot be authorise
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(req_username:, collab_email:, note_id:)
      account = Account.first(username: req_username)
      note = Note.first(id: note_id)
      authorise = Account.first(email: collab_email)

      policy = AuthoriseRequestPolicy.new(note, account, authorise)
      raise ForbiddenError unless policy.can_remove?

      note.remove_authorise(authorise)
      authorise
    end
  end
end
