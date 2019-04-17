# frozen_string_literal: true

require 'roda'
require 'json'

#require_relative '../models/document'
#require_relative '../models/inheritor'
#require_relative '../models/note'

module LastWillFile
  # Web controller for Credence API
  class Api < Roda
    #plugin :environments
    plugin :halt
=begin
    configure do
      Document.setup
      Inheritor.setup
      Note.setup
    end
=end
    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'LastWillFileAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'projects' do
          @proj_route = "#{@api_root}/projects"

          routing.on String do |proj_id|
            routing.on 'documents' do
              @doc_route = "#{@api_root}/projects/#{proj_id}/documents"
              # GET api/v1/projects/[proj_id]/documents/[doc_id]
              routing.get String do |doc_id|
                doc = Document.where(project_id: proj_id, id: doc_id).first
                doc ? doc.to_json : raise('Document not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/projects/[proj_id]/documents
              routing.get do
                output = { data: Project.first(id: proj_id).documents }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find documents'
              end

              # POST api/v1/projects/[ID]/documents
              routing.post do
                new_data = JSON.parse(routing.body.read)
                proj = Project.first(id: proj_id)
                new_doc = proj.add_document(new_data)

                if new_doc
                  response.status = 201
                  response['Location'] = "#{@doc_route}/#{new_doc.id}"
                  { message: 'Document saved', data: new_doc }.to_json
                else
                  routing.halt 400, 'Could not save document'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/projects/[ID]
            routing.get do
              proj = Project.first(id: proj_id)
              proj ? proj.to_json : raise('Project not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # GET api/v1/projects
          routing.get do
            output = { data: Project.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find projects' }.to_json
          end

          # POST api/v1/projects
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_proj = Project.new(new_data)
            raise('Could not save project') unless new_proj.save

            response.status = 201
            response['Location'] = "#{@proj_route}/#{new_proj.id}"
            { message: 'Project saved', data: new_proj }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end  
=begin
      #routing.on 'api' do
       # routing.on 'v1' do
        # routing.on 'documents' do
            # GET api/v1/documents/[id]
            routing.get String do |id|
              Document.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Document not found' }.to_json
            end

            # GET api/v1/documents
            routing.get do
              output = { document_ids: Document.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/documents
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Document.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Document saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save Document' }.to_json
              end
            end
          end

          routing.on 'inheritors' do
            # GET api/v1/inheritors/[id]
            routing.get String do |id|
              Inheritor.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Inheritor not found' }.to_json
            end

            # GET api/v1/inheritor
            routing.get do
              output = { inheritor_ids: Inheritor.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/inheritors
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Inheritor.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Inheritor saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save Inheritor' }.to_json
              end
            end
          end

          routing.on 'notes' do
            # GET api/v1/notes/[id]
            routing.get String do |id|
              Note.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'note not found' }.to_json
            end

            # GET api/v1/note
            routing.get do
              output = { note_ids: Note.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/notes
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Note.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'note saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save Note' }.to_json
              end
            end
          end

        end
      end

    end
  end
end
=end