# frozen_string_literal: true
require 'pry'
require 'date'

#Name of the common module
module LastWillFile
  # get the available existences in the database for one specific account
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
      notes = Account.first(id: account_id).executors
      existences = []
      costumers = []

      notes.each do |row|
        existences.push(row.title)
        account = Account.first(id: row.owner.id)
        existence = Existence.first(owner_id: row.owner.id)

        puts existence.updated_at
        puts Date.today

        less = Date.today - existence.updated_at

        costumers.push({title: row.title, name: account.email, time: existence.timer})
      end

      costumers
    end
  end
end
