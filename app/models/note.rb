# frozen_string_literal: true

require 'json'
require 'sequel'

module LastWillFile
  # Models a secret Note
  class Note < Sequel::Model
    one_to_many :inheritors
    plugin :association_dependencies, inheritors: :destroy

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
        JSON(
          {
            data: {
              type: 'note',
              attributes: {
                id: id,
                description: description,
                inheritor_ids: inheritor_ids,
                files_ids: files_ids
              }
            }
          }, options
        )
    end
      # rubocop:enable MethodLength
  end

end
