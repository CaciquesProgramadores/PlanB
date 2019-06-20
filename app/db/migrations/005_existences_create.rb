# frozen_string_literal: true

require 'sequel'
# require 'securerandom'

Sequel.migration do
  change do
    create_table(:existences) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :email, null: false, unique: true
      int :timer
      int :type

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
