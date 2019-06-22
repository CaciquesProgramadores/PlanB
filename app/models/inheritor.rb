# frozen_string_literal: true

require 'json'
require 'sequel'

module LastWillFile
  # Models a secret document
  class Inheritor < Sequel::Model
    many_to_one :note

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :description, :relantionship, :emails, :phones, :nickname, :pgp, :fullname

    plugin :uuid, field: :id

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
          type:       'inheritor',
          attributes: public_attributes_hash,
          include:    includes_hash
        }, options
      )
    end
    # rubocop:enable MethodLength

    def public_attributes_hash
      {
        id: id,
        description: description,
        relantionship: relantionship,
        emails: emails,
        phones: phones,
        nickname: nickname,
        pgp: pgp,
        fullname: fullname
      }
    end

    def includes_hash
      { note: note }
    end
  end
end
