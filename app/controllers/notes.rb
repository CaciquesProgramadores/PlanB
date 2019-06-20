# frozen_string_literal: true

require_relative './app'
require 'pry'

# rubocop:disable Metrics/BlockLength
module LastWillFile
  # Web controller for LastwillFile API
  class Api < Roda
    route('notes') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @note_route = "#{@api_root}/notes"
      routing.on String do |note_id|
        @req_note = Note.first(id: note_id)

        # GET api/v1/notes/[ID]
        routing.get do
          note = GetNoteQuery.call(auth: @auth, note: @req_note)

          { data: note }.to_json
        rescue GetNoteQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetNoteQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND NOTE ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('inheritors') do
          # POST api/v1/notes/[note_id]/inheritors
          routing.post do
            new_inheritor = CreateInheritor.call(
              #account: @auth_account,
              auth: @auth,
              note: @req_note,
              inheritor_data: JSON.parse(routing.body.read)
              #binding.pry
            )
            
            response.status = 201
            response['Location'] = "#{@doc_route}/#{new_inheritor.id}"
            { message: 'Inheritor saved', data: new_inheritor }.to_json
          rescue CreateInheritor::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateInheritor::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE INHERITOR ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('authorises') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/notes/[note_id]/authorises
          routing.put do
            req_data = JSON.parse(routing.body.read)
            authorised = AddAuthorise.call(auth: @auth, project: @req_note, collab_email: req_data['email'])

            { data: authorised }.to_json
            
          rescue AddAuthorise::ForbiddenError => e
            #binding.pry
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/notes/[note_id]/authorises
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            authorised = RemoveAuthorise.call(
              #req_username: @auth_account.username,
              auth: @auth,
              authorises_email: req_data['email'],
              note_id: note_id
            )

            { message: "#{authorised.username} removed from note",
            data: authorised }.to_json
          rescue RemoveAuthorise::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing .is do
        # GET api/v1/notes
        routing.get do
          notes = NotePolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: notes)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any notes' }.to_json
        end

         # POST api/v1/notes
         routing.post do
          new_data = JSON.parse(routing.body.read)

          new_proj = CreateNoteForOwner.call(
            auth: @auth, note_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@note_route}/#{new_proj.id}"
          { message: 'Note saved', data: new_proj }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateNoteForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/notes/
        routing.put do
          new_data = JSON.parse(routing.body.read)
         
          new_proj = UpdateNoteForOwner.call(
            auth: @auth, note_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@note_route}/#{new_proj.id}"
          { message: 'Note saved', data: new_proj }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue UpdateNoteForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/notes/
        routing.delete do
          req_data = JSON.parse(routing.body.read)
         
          delnote = RemoveNote.call(
            req_username: @auth_account.username,
            note_id: req_data['id']
          )

          { message: "#{delnote.title} note removed",
          data: authorised }.to_json
        rescue RemoveNote::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

      end
    end
  end
end
# rubocop:enable Metrics/BlockLength