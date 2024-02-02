# Weather  (A Rails Application)

This is a web application that serves basic weather information given a requested Zip Code.  To satisfy basic needs, it currently retrieves external weather data and caches results by zip code for display.  

## Design

At this stage of functionality, no database is needed since the only persisted data is cached from api calls and renders.


## Weather Data

This project was set up to use the [Tomorrow API](https://www.tomorrow.com/api). You will need to sign up and create a free account in order to get your own api key.

To configure the api key for the application, set the environment variablie `TOMORROW_API_KEY` so that it will
be available to the Rails application.

To keep data retrieval and caching simple, only a zip code is needed. In the future if may be desireable to support more specific geolocation, which will have an impact on how much cache space is needed.

## Setup



## Caching

Weather data is cached for 30 minutes by zip code, along with the views that will not change until the data is refreshed.

* Ruby version

Tested with Ruby 3.3.0.

## System dependencies

To minimize initial dependencies, the project relies on Rails default cache mechanisms which may not be suitable for certain deployment needs.  To change, configure a different cache store in Rails.

Current Dependencies:

* Ruby 3.3.x
* Nodejs

## Running

`bundle exec rails server`

## Running tests

`bundle exec rspec`