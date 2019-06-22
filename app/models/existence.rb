# frozen_string_literal: true

require 'json'
require 'sequel'

module LastWillFile
  # Models a secret document
  class Existence < Sequel::Model
    many_to_one :owner, class: :'LastWillFile::Account'

    plugin :timestamps, update_on_create: true

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
            type: 'existence',
            attributes: {
              id: id,
              email: email,
              timer: timer,
              type: type
          }

        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
