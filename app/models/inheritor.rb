# frozen_string_literal: true

require 'json'
require 'sequel'

module LastWillFile
  # Models a secret document
  class Inheritor < Sequel::Model
    many_to_one :note

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :description, :relantionship, :emails, :phones, :nickname, :pgp, :fullname

    # secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def relantionship
      SecureDB.decrypt(relantionship_secure)
    end

    def relantionship=(plaintext)
      self.relantionship_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'inheritor',
            attributes: {
                id: id,
                description: description,
                relantionship: relantionship,
                emails: emails,
                phones: phones,
                nickname: nickname,
                pgp: pgp,
                fullname: fullname
            }
          },
          included: {
            note: note
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
