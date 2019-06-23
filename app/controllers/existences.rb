# frozen_string_literal: true

require_relative './app'
require 'pry'

module LastWillFile
  # Web controller for LastWillFile API
  class Api < Roda
    route('existences') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @doc_route = "#{@api_root}/existences"

      # GET api/v1/existences/
      routing .is do
        routing.get do
          existences = GetExistencesQuery.call(
            auth: @auth, account_id: @auth[:account].id
          )
          # { data: existences }.to_json	
          JSON.pretty_generate(data: existences)
        rescue StandardError => e
          puts "GET Existence ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end
      end
    end
  end
end
