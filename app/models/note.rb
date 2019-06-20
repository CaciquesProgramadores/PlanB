# frozen_string_literal: true

require 'json'
require 'sequel'
# require 'securerandom'

module LastWillFile
  # Models a secret Note
  class Note < Sequel::Model
    many_to_one :owner, class: :'LastWillFile::Account'

    many_to_many :executors,
                 class: :'LastWillFile::Account',
                 join_table: :accounts_notes,
                 left_key: :note_id, right_key: :executor_id

    one_to_many :inheritors
    plugin :association_dependencies,
           inheritors: :destroy,
           executors: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :description, :files_ids, :title
    
    def inheritor_ids
      inheritors.map(&:id)
    end

    # secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'note',
        attributes: {
          id: id,
          description: description,
          files_ids: files_ids,
          title: title
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner: owner,
          executors: executors,
          inheritors: inheritors
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
