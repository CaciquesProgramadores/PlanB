# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

## LastWillFile to be leaved
module LastWillFile
  ## Notes to be leaved
  class Note
    STORE_DIR = 'app/db/store/notes'

    # Create a new note by passing in hash of attributes
    def initialize(new_document)
      @id          = new_document['id'] || new_id
      @description = new_document['description']
      @inheritor_ids    = new_document['inheritor_ids']
      @files_ids     = new_document['files_ids']
    end

    attr_reader :id, :description, :inheritor_ids, :files_ids

    def to_json(options = {})
      JSON(
        {
          type: 'document',
          id: id,
          description: description,
          inheritor_ids: inheritor_ids,
          files_ids: files_ids
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

    # Query method to find one note
    def self.find(find_id)
      note = File.read(STORE_DIR + find_id + '.txt')
      Document.new JSON.parse(note)
    end

    # Query method to retrieve index of all notes
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
