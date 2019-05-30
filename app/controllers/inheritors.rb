# frozen_string_literal: true

require_relative './app'

module LastWillFile
  # Web controller for LastWillFile API
  class Api < Roda
    route('inheritors') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @doc_route = "#{@api_root}/inheritors"

      # GET api/v1/inheritors/[doc_id]
      routing.on String do |doc_id|
        @req_inheritor = Inheritor.first(id: doc_id)

        routing.get do
          inheritor = GetInheritorQuery.call(
            requestor: @auth_account, inheritor: @req_inheritor
          )

          { data: inheritor }.to_json
        rescue GetDocumentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetInheritorQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET INHERITOR ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
