# LastWill API

A LastWill API - our web and mobile Project for the class Service Security

The LastWill API allow users to create and store their legal will, pictures, stories, memo, notes, memories..etc, which can be shared to their love ones after they pass. The app can be useful for eldery citizens, caretakers,  patients with terminal stage dieseases, military full-time service personel, anyone in a higher risk roles/jobs etc.  This project will focus on high data privacy and security and also intelligent sharing and distribution functionality.

It includes the following features:
  - create/edit user/patient decease confirmation/validation and control rules.
  - add/edit inheritor(s) or legal representative(s) notification and reminder.
  - add/edit/delete documents (types: Will, Photos, Memo, stories, notes..etc)
  - use recent and reliable hashing, encryption and decryption algorithms for tokening, signing and verifying.
  - have both Web and mobile UI(coming soon)
  - etc..

 Required development enviroment:
  - Language Ruby 2.6.2
  - Roda framework -v 3.18

 Other Required packages:
   - Rack
   - libsodium32 -rbnacl
   - see gem file for full detail

## API route and methods:

All routes return Json
- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/notes/[proj_id]/inheritor/[doc_id]`: Get a inheritor
- GET  `api/v1/notes/[proj_id]/inheritors`: Get list of inheritors for particular note
- POST `api/v1/notes/[ID]/inheritors`: create inheritor for a project
- GET  `api/v1/notes/[ID]`: Get information about a note
- GET  `api/v1/notes`: Get list of all note
- POST `api/v1/notes`: Create new note

#Note
- Ensure to create dir app/db/store before attempting shell below.

## Install
-Install this API by cloning the relevant branch and installing required gems from Gemfile.lock:

## Execute

Run this API using:

 ```shell
  bundle install
 ```
Setup development database once:

```shell
rake db:migrate
```

## Execute

Run this API using:

```shell
rackup
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

