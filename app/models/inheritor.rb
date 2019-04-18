# frozen_string_literal: true

require 'json'
require 'sequel'

module LastWillFile
  # Models a secret document
  class Inheritor < Sequel::Model
    many_to_one :note

    plugin :timestamps

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
