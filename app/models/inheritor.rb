# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

## LastWillFile to be leaved
module LastWillFile
  ## Inheritor to be used by many objects and classes
  class Inheritor
    STORE_DIR = 'app/db/store/inheritors/'

    # Create a new note by passing in hash of attributes
    def initialize(new_document)
      @id = new_document['id'] || new_id
      @description = new_document['description']
      @relantionship = new_document['relantionship']
      @emails = new_document['emails']
      @phones = new_document['phones']
      @pgp = new_document['pgp']
      @fullname = new_document['fullname']
      @nickname = new_document['nickname']
    end

    attr_reader :id, :description, :relantionship, :emails
    attr_reader :phones, :pgp, :fullname, :nickname

    def to_json(options = {})
      JSON(
        {
          type: 'document', id: id,
          description: description, emails: emails,
          relantionship: relantionship,
          phones: phones, nickname: nickname,
          pgp: pgp, fullname: fullname
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    # Stores a person in a document in file store
    def save
      File.write(STORE_DIR + id + '.txt', to_json)
    end

    # Query method to find one person
    def self.find(find_id)
      document_file = File.read(STORE_DIR + find_id + '.txt')
      Document.new JSON.parse(document_file)
    end

    # Query method to retrieve index of all people
    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |file|
        file.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
