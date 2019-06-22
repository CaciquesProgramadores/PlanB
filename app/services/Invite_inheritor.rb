# frozen_string_literal: true

require 'http'
require 'pry'

module LastWillFile
  # Send email verfification email
  class InviteInheritor
    # Error for invalid registration details
    class InvalidInvitation < StandardError; end

    def initialize(config, auth, invitation_info)
      @config = config
      @auth  = auth
      @invitation_info = invitation_info
    end

    def call
      raise(InvalidInvitation, 'Email already a member') unless email_available?

      send_email_invitation
    end

    def call_rechecking
      raise(InvalidInvitation, 'Email already a member') unless email_available?
    end

    def email_available?
      Account.first(email: @invitation_info[:data]['inh_email']).nil?
    end

    def email_body
      verification_url = @invitation_info[:data]['verification_url']

      <<~END_EMAIL
        <H1>Planb Invitation Received<H1>
        <p>You been invited to planb by a member with this email address " #{@auth[:account].email}Please <a href=\"#{verification_url}\">click here</a> to validate your
        email. You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_invitation
      email = @invitation_info[:data]['inh_email']#.strip
      HTTP.auth(
        "Bearer #{@config.SENDGRID_API_KEY}"
      ).post(
        @config.SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' =>  email }]
          }],
          from: { 'email' => 'noreply@planb.com' },
          subject: 'PlanB Invititation',
          content: [
            { type: 'text/html',
              value: email_body }
          ]
        }
      )
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidInvitation,
            'Could not send invitation ; please check email address')
    end
    # rubocop:enable Metrics/MethodLength
  end
end
