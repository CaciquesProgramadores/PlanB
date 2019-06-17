# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers.rb'

# # rubocop:disable Metrics/BlockLength
module LastWillFile
  # Web controller for Credence API
  class Api < Roda
    plugin :halt
    plugin :all_verbs
    plugin :multi_route
    plugin :request_headers
    include SecureRequestHelpers

<<<<<<< HEAD
    UNAUTH_MSG = { message: 'Unauthorized Request' }.to_json

    #def secure_request?(routing)
     # routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    #end

=======
>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9
    UNAUTH_MSG = { message: 'Unauthorized Request' }.to_json

    route do |routing|
      response['Content-Type'] = 'application/json'
      # problema aqui
      secure_request?(routing) ||
        routing.halt(403, {message: 'TLS/SSL Required'}.to_json)

      begin
<<<<<<< HEAD
        # @auth_account = authenticated_account(routing.headers)
=======
>>>>>>> c19c8e26711ffff6380b4fd1a3bf07fc654120c9
        @auth = authorization(routing.headers)
        @auth_account = @auth[:account] if @auth
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      rescue AuthToken::ExpiredTokenError
        routing.halt 403, { message: 'Expired auth token' }.to_json
      end

      routing.root do
        { message: 'LastWillAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
# # rubocop:enable Metrics/BlockLength
