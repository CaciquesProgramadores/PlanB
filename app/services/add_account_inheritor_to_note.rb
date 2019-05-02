# frozen_string_literal: true

module LastWillFile
  # Add a inheritor who has an account in the system
  class AddAccountInheritorToNote
    def self.call(email:, note_id:)
      acc_inheritor = Account.first(email: email)
      note = Note.first(id: note_id)
      return false if note.owner.id == acc_inheritor.id

      acc_inheritor.add_note(note)
      acc_inheritor
    end
  end
end
