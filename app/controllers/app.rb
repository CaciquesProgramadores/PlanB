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
        routing.on 'notes' do
          @proj_route = "#{@api_root}/notes"

          routing.on String do |n_id|
            routing.on 'inheritors' do
              @doc_route = "#{@api_root}/notes/#{n_id}/inheritors"
              # GET api/v1/notes/[note_id]/inheritors/[inh_id]
              routing.get String do |inh_id|
                doc = Inheritor.where(note_id: n_id, id: inh_id).first
                doc ? doc.to_json : raise('Inheritor not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/notes/[note_id]/inheritors
              routing.get do
                output = { data: Note.first(id: n_id).inheritors }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find inheritors'
              end

              # POST api/v1/notes/[ID]/inheritors
              routing.post do
                new_data = JSON.parse(routing.body.read)
                mynote = Note.first(id: n_id)
                new_inh = mynote.add_inheritor(new_data)

                if new_inh
                  response.status = 201
                  response['Location'] = "#{@doc_route}/#{new_inh.id}"
                  { message: 'Inheritor saved', data: new_inh }.to_json
                else
                  routing.halt 400, 'Could not save inheritor'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/notes/[ID]
            routing.get do
              mynote = Note.first(id: n_id)
              mynote ? mynote.to_json : raise('Note not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
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
            new_note = Note.new(new_data)
            raise('Could not save note') unless new_note.save

            response.status = 201
            response['Location'] = "#{@proj_route}/#{new_note.id}"
            { message: 'Note saved', data: new_note }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength