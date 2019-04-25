# frozen_string_literal: true

require 'sequel'
# require 'securerandom'

Sequel.migration do
  change do
    create_table(:notes) do
      primary_key :id
      # uuid :id, primary_key: true

      String :description, null: false
      String :files_ids

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
