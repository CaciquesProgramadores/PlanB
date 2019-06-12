# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, notes, inheritors'
    create_accounts
    create_owned_notes
    create_inheritors
    #add_account_inheritors
    add_authorises
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_notes.yml")
NOTE_INFO = YAML.load_file("#{DIR}/notes_seeds.yml")
INHERITOR_INFO = YAML.load_file("#{DIR}/inheritor_seeds.yml")
ACC_INHERITORS_INFO = YAML.load_file("#{DIR}/notes_authorises.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    LastWillFile::Account.create(account_info)
  end
end

def create_owned_notes
  OWNER_INFO.each do |owner|
    account = LastWillFile::Account.first(username: owner['username'])
    owner['title'].each do |note_name|
      note_data = NOTE_INFO.find { |note| note['title'] == note_name }
      LastWillFile::CreateNoteForOwner.call(
        #owner_id: account.id, note_data: note_data
        account.add_owned_note(note_data)
      )
    end
  end
end

def create_inheritors
  inh_info_each = INHERITOR_INFO.each
  notes_cycle = LastWillFile::Note.all.cycle
  loop do
    inh_info = inh_info_each.next
    note = notes_cycle.next
    LastWillFile::CreateInheritorForNote.call(
      note_id: note.id, inheritor_data: inh_info
    )
  end
end

def add_authorises
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    proj = LastWillFile::Note.first(title: contrib['title'])
    contrib['authorises_email'].each do |email|
      LastWillFile::AddAuthoriseToNote.call(
        email: email, note_id: proj.id
      )
    end
  end
end

=begin
def add_account_inheritors
  acc_inh_info = ACC_INHERITORS_INFO
  acc_inh_info.each do |acc_inh|
    note = LastWillFile::Note.first(title: acc_inh['title'])
    acc_inh['authorises_email'].each do |email|
      LastWillFile::Account.call(
        email: email, note_id: note.id
      )
      #note.add_authorise(acc_inheritor)
    end
  end
end
=end
