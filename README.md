# LastWill API

A LastWill Api - our web and mobile Project for the class Service Security

The LastWill app is an application which allow users to create and store their legal will, pictures, stories, memo, notes, memories..etc, which can be shared to their love ones after they pass. The app can be useful for eldery citizens, caretakers,  patients with terminal stage dieseases, military full-time service personel, anyone in a higher risk roles/jobs etc.  This project will focus on high data privacy and security and also intelligent sharing and distribution functionality.

It includes the following features:
  - create/edit user/patient decease confirmation/validation and control rules.
  - add/edit inheritor(s) or legal representative(s) notification and reminder.
  - add/edit/delete documents (types: Will, Photos, Memo, stories, notes..etc)
  - use recent and reliable hashing, encryption and decryption algorithms
  - have both Web and mobile UI
  - etc..

 Required development enviroment:
  - Language Ruby 2.6.2
  - Roda framework -v 3.18
  - MySql/POSTREGSQL database
  - Flutter /dart mobile platform.

 Other Required packages:
   - Rack
   - libsodium18 -rbnacl
   - see gem file for full detail

  Developers email contacts:
   - Jonathan - jonathanolivataiwan@gmail.com
   - Teaka Moaniba - esamgel@gmail.com

  Reference: base on soumyaray ISS secuity repo @ https://github.com/ISS-Security/credence-api/tree/0_api_mvc

  ## Routes

  All routes return Json

  - GET `/`: Root route shows if Web API is running

  - GET `api/v1/documents/`: returns all documents IDs
  - GET `api/v1/documents/[ID]`: returns details about a single document with given ID
  - POST `api/v1/documents/`: creates a new document

  - GET `api/v1/inheritors/`: returns all inheritors IDs
  - GET `api/v1/inheritors/[ID]`: returns details about a single inheritor with given ID
  - POST `api/v1/inheritors/`: creates a new inheritor

  - GET `api/v1/notes/`: returns all notes IDs
  - GET `api/v1/notes/[ID]`: returns details about a single note with given ID
  - POST `api/v1/notes/`: creates a new note

  ## Install

  Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

  ```shell
  bundle install
  ```

  ## Test

  Run the test script:

  ```shell
  ruby spec/api_spec.rb
  ```

  ## Execute

  Run this API using:

  ```shell
  rackup
  ```  
