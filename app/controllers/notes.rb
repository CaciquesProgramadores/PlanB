# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module LastWillFile
  # Web controller for Credence API
  class Api < Roda
    route('notes') do |routing|
      # unauthorized_message = { message: 'Unauthorized Request' }.to_json
      # routing.halt(403, unauthorized_message) unless @auth_account
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @note_route = "#{@api_root}/notes"
      routing.on String do |note_id|
        @req_note = Note.first(id: note_id)

        # GET api/v1/notes/[ID]
        routing.get do
<<<<<<< HEAD
          # note = GetNoteQuery.call(
            # account: @auth_account, note: @req_note
          # )
=======

>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9
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
             # account: @auth_account,
              auth: @auth,
              note: @req_note,
              inheritor_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@inheritor_route}/#{new_inheritor.id}"
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

            authorised = AddAuthorise.call(
              #account: @auth_account,
              auth: @auth,
              note: @req_note,
              authorises_email: req_data['email']
            )

            { data: authorised }.to_json
          rescue AddAuthorise::ForbiddenError => e
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
=begin
        # POST api/v1/notes
        routing.post do
          new_data = JSON.parse(routing.body.read)
          #new_proj = @auth_account.add_owned_note(new_data)

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
=end
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
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
