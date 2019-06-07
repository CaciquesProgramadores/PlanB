# frozen_string_literal: true

module LastWillFile
  # Add a authorises to another owner's existing note
  class CreateInheritor
    # Error for owner cannot be authorises
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more inheritors'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a inheritor with those attributes'
      end
    end

    # def self.call(account:, note:, inheritor_data:)
      #policy = NotePolicy.new(account, note)
    def self.call(auth:, note:, inheritor_data:)
      policy = NotePolicy.new(auth[:account], note, auth[:scope])
      raise ForbiddenError unless policy.can_add_inheritors?

   #   add_inheritor(note, inheritor_data)
    #end

    #def self.add_inheritor(note, inheritor_data)
      note.add_inheritor(inheritor_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
