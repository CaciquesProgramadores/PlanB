# frozen_string_literal: true

module LastWillFile
  # Service object to create a new note for an owner
  class UpdateExistence
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are can note change your existence'
      end
    end

    def self.call(auth:, existence_data:)

      # raise ForbiddenError unless auth[:scope].can_write?('notes')
      puts "cuento 1"
      existence = Existence.find(email: existence_data['email'])
      puts "cuento 2"
      existence_data = { email: existence_data['email'], timer: 10, type: 1 }
      puts "cuento 3"
      if existence == nil
        auth[:account].add_existence(existence_data)
      else
        no_key = existence_data.reject{|k,v| k == "id" || k == "email"}
        existence.update(no_key)
      end
    end
  end
end
