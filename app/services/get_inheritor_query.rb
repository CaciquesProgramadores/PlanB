# frozen_string_literal: true

module LastWillFile
  # Add a collaborator to another owner's existing project
  class GetInheritorQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that inheritor'
      end
    end

    # Error for cannot find a project
    class NotFoundError < StandardError
      def message
        'We could not find that inheritor'
      end
    end

    # Inheritor for given requestor account
    # def self.call(requestor:, inheritor:)
    def self.call(auth:, inheritor:)
      raise NotFoundError unless inheritor

      # policy = InheritorPolicy.new(requestor, inheritor)
      policy = InheritorPolicy.new(auth[:account], inheritor, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      inheritor
    end
  end
end
