# Weather  (A Rails Application)

This is a web application that serves basic weather information given a requested Zip Code.  To satisfy basic needs, it currently retrieves external weather data and caches results by zip code for display.  

## Design Notes

At this stage of functionality, no database is needed since the only persisted data is cached from api calls and renders.  This decision keeps things simple initially, but could evolve to store fetched results in an application database potentially with enhanced data, longer history, etc.  SQLite 3 is left as a dependency though could be removed if not planning to add functionality requiring a database. 

Since the initial assumptions of the project were to cache results by zip code, address entry kept simple to bootstrap the process.  Ultimately, the application could add searching based on Address, city, etc. to help users search a location if they don't know the zip code.  

Since this first pass focuses on fetching results at the zip-code level only, we encounter the issue that zip codes are not unique across all geographic areas (mainly country). So at this stage, US zip code lookup is enforced.  We make the assumption that cities that share a zip code in the US are geographically close such that results can be shared.

Currently the applicaiton displays current conditions, but is set up to make a second call for forecast information to render as well.  For most free API plans this requires two calls though there are some paid plans that provide a single endpoint to get both sets of data.

All data is currently forced to imperial units, though with an extra API parameter and a bit more view logic this could become user selectable.

## Weather Data Source

This project was set up to use the [Tomorrow API](https://www.tomorrow.io). You will need to sign up and create a free account in order to get your own api key.

To configure the api key for the application, set the environment variablie `TOMORROW_API_KEY` so that it will
be available to the Rails application.

To keep data retrieval and caching simple, only a zip code is needed. In the future if may be desireable to support more specific geolocation, which will have an impact on how much cache space is needed.

## Setup

Run rails css:build
For production, make sure to run rails assets:precompile.


## Caching

Weather data is cached for 30 minutes by zip code, along with the views that will not change until the data is refreshed.

To test caching in development mode, remember to enable caching with `rails dev:cache`

##  Versions

* Ruby version 3.3.x 
* Rails 7.1.X

Tested with Ruby 3.3.0.

## System dependencies

To minimize initial dependencies, the project relies on Rails default cache mechanisms which may not be suitable for certain deployment needs.  To change, configure a different cache store in Rails.

Current Dependencies:

* Ruby 3.3.x
* Nodejs
* yarn
* sqlite3

## Running

`bundle exec rails server`

## Running tests

`bundle exec rspec`