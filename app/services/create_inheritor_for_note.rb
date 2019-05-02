# frozen_string_literal: true

module LastWillFile
  # Create new configuration for a # NOTE:
  class CreateInheritorForNote
    def self.call(note_id:, inheritor_data:)
      Note.first(id: note_id)
             .add_inheritor(inheritor_data)
    end
  end
end
