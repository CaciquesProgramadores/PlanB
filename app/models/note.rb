# frozen_string_literal: true

require 'json'
require 'sequel'
# require 'securerandom'

module LastWillFile
  # Models a secret Note
  class Note < Sequel::Model
    many_to_one :owner, class: :'LastWillFile::Account'

    many_to_many :authorises,
                 class: :'LastWillFile::Account',
                 join_table: :accounts_notes,
                 left_key: :note_id, right_key: :authorise_id

    one_to_many :inheritors
    plugin :association_dependencies,
           inheritors: :destroy,
           authorises: :nullify

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

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
            type: 'note',
            attributes: {
              id: id,
              description: description,
              files_ids: files_ids,
              title: title
            }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
