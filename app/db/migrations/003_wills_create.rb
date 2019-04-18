# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:wills) do
      String :note_id
      String :inheritor_id

      primary_key [:note_id, :inheritor_id], name: :items_pk
      foreign_key [:note_id], :notes, name: :wills_note_id_fkey
      foreign_key [:inheritor_id], :inheritors, name: :wills_inheritor_id_fkey

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
