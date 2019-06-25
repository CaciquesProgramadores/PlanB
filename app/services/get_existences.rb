# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Add a collaborator to another owner's existing note
  class GetExistencesQuery
    # Error for owner cannot be executer
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that existence'
      end
    end

    # Error for cannot find a note
    class NotFoundError < StandardError
      def message
        'We could not find that existence'
      end
    end

    def self.call(auth:, account_id:)
      # get notes where I m the executer
      notes = Account.first(id: account_id).executors
      existences = []
      costumers = []

      notes.each do |row|
        existences.push(row.title)
        account = Account.first(id: row.owner.id)
        costumers.push({title: row.title, name: account.email})
      end
      # get the emails for the existences
      # emails = []
      # owner_ids.each do |i|
      #   emails.push(Account.find(id: i).email)
      # end
      #
      # # get existences
      # # existences = []
      # # emails.each do |e|
      # #   existences.push(Account.find(email: e))
      # # end
      #
      # emails

      costumers
    end
  end
end
