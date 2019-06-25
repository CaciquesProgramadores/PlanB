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
      authorises = Account.find(id: account_id).executors
      owner_ids = []
      puts 'hello q1'
      puts authorises[0]['note_id']
      puts 'hello 2'

      authorises.each do |row|
        note = Note.first(id: row['note_id'])
        puts 'is null' if note == nil

        owner_ids.push(note.owner.id)
      end
      # get the emails for the existences
      emails = []
      owner_ids.each do |i|
        emails.push(Account.find(id: i).email)
      end

      # get existences
      # existences = []
      # emails.each do |e|
      #   existences.push(Account.find(email: e))
      # end

      emails
    end
  end
end
