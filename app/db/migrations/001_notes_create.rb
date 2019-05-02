# frozen_string_literal: true

require 'sequel'
# require 'securerandom'

Sequel.migration do
  change do
    create_table(:notes) do
      primary_key :id
      foreign_key :owner_id, :accounts
      # uuid :id, primary_key: true

      String :description_secure, null: false
      String :files_ids
      String :title, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
