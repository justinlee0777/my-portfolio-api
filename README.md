# My Portfolio API

API for my portfolio site.

08/28/2024: As of this date, the API is obsolete and migrated to NodeJS. However, the Random of the Day cron job is still in use.

## Random of the Day

The purpose of the project is to generate a random thing to amuse people during the work week. Currently it supports a random poem, fact, and painting.

The `generator` project is ran as an Amazon Web Services (AWS) Lambda at 12:00am every week day.

The `web` project is deployed onto AWS Elastic Beanstalk and returns saved data on AWS DynamoDB.

More details in the individual folders.

## Scripts

`./scripts/upload-poem.rb` is used to upload poems to DynamoDB, for ease.

Run `bundle exec rubocop` to run the RuboCop formatter on the project.