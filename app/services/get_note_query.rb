# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Add a collaborator to another owner's existing note
  class GetNoteQuery
    # Error for owner cannot be executer
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that note'
      end
    end

    # Error for cannot find a note
    class NotFoundError < StandardError
      def message
        'We could not find that note'
      end
    end

    def self.call(auth:, note:)
      raise NotFoundError unless note

      policy = NotePolicy.new(auth[:account], note, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      note.full_details.merge(policies: policy.summary)
    end
  end
end
