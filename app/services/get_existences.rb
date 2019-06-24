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
      puts "authorises"
      puts authorises
      owner_ids = []
      authorises.each do |row|
        owner_ids.push(Note.find(id: row['note_id']).owner_id)
      end
      puts "owner_ids"
      puts owner_ids
      # get the emails for the existences
      emails = []
      owner_ids.each do |i|
        emails.push(Account.find(id: i).email)
      end

      puts "emails"
      puts emails
      # get existences
      # existences = []
      # emails.each do |e|
      #   existences.push(Account.find(email: e))
      # end

      emails
    end
  end
end