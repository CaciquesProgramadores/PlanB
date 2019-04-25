# frozen_string_literal: true

require 'json'
require 'sequel'
require 'securerandom'

module LastWillFile
  # Models a secret Note
  class Note < Sequel::Model
    one_to_many :inheritors
    plugin :association_dependencies, inheritors: :destroy

    # plugin :uuid, field: :id

    plugin :timestamps

    plugin :whitelist_security
    set_allowed_columns :description, :files_ids

    def inheritor_ids
      inheritors.map(&:id)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
        JSON(
          {
            data: {
              type: 'note',
              attributes: {
                id: id,
                description: description,
                files_ids: files_ids
              }
            }
          }, options
        )
    end
      # rubocop:enable MethodLength
  end

end
