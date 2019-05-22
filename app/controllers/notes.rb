# frozen_string_literal: true

require 'roda'
require_relative './app'

# rubocop:disable Metrics/BlockLength
module LastWillFile
  # Web controller for Credence API
  class Api < Roda
      route('notes') do |routing|
        @note_route = "#{@api_root}/notes"

        routing.on String do |notee_id|
          routing.on 'inheritors' do
            @inheritor_route = "#{@api_root}/notes/#{notee_id}/inheritors"

            # GET api/v1/notes/[notee_id]/inheritors/[inh_id]
            routing.get String do |inh_id|
              doc = Inheritor.where(note_id: notee_id, id: inh_id).first
              doc ? doc.to_json : raise('Inheritor not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # GET api/v1/notes/[notee_id]/inheritors
            routing.get do
              output = { data: Note.first(id: notee_id).inheritors }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find Inheritors' }.to_json
            end

            # POST api/v1/notes/[notee_id]/inheritors
            routing.post do
              new_data = JSON.parse(routing.body.read)
              proj = Note.first(id: notee_id)
              new_doc = proj.add_inheritor(new_data)
              raise 'Could not save inheritor' unless new_doc

              response.status = 201
              response['Location'] = "#{@doc_route}/#{new_doc.id}"
              { message: 'Inheritor saved', data: new_doc }.to_json
            rescue Sequel::MassAssignmentRestriction
              routing.halt 400, { message: 'Illegal Request' }.to_json
            rescue StandardError
              routing.halt 500, { message: 'Database error' }.to_json
            end
          end

          # GET api/v1/notes/[ID]
          routing.get do
            proj = Note.first(id: notee_id)
            proj ? proj.to_json : raise('Note not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # GET api/v1/notes
        routing.get do
          account = Account.first(username: @auth_account['username'])
          notes = account.notes
          JSON.pretty_generate(data: notes)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any notes' }.to_json
        end

        # POST api/v1/notes
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_proj = Note.new(new_data)
          raise('Could not save note') unless new_proj.save

          response.status = 201
          response['Location'] = "#{@proj_route}/#{new_proj.id}"
          { message: 'Note saved', data: new_proj }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => e
          routing.halt 500, { message: e.message }.to_json
        end
      end
  end
end
