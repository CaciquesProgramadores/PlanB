# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:notes) do
      primary_key :id

      String :description, null: false
      String :files_ids

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
