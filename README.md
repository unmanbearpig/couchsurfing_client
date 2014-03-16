CouchSurfingClient
=========

Unofficial client for CouchSurfing.org written in Ruby.
You need an account to use it.

## Signing in to CouchSurfing

To use it you need to sign in first. To do that initialize CouchSurfing instance with your
username and password and call sign_in method on it.
```ruby
cs = CouchSurfingClient.CouchSurfing.new USERNAME, PASSWORD
cs.sign_in
```
## Fetching a profile

You can fetch a couchsurfing profile by its id:
```ruby
cs.get_profile_by_id "CSID"
```
or by its relative or absolute url:
```ruby
cs.get_profile_by_url '/people/person'
```
or
```ruby
cs.get_profile_by_url 'https://www.couchsurfing.org/people/person/'
```
## Location

To search for anything in a specific city you need to get an
appropriate location instance.
To find a location use find_location(name) method, it
returns an array of location instances using couchsurfing's ajax
location suggest API.
```ruby
cs.find_location('Seoul')
```
## Searching

TODO
