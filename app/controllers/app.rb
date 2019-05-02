# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/BlockLength
module LastWillFile
  # Web controller for Credence API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'LastWillAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts error.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end

        routing.on 'notes' do
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
            output = { data: Note.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find notes' }.to_json
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
  end
end
# rubocop:enable Metrics/BlockLength
