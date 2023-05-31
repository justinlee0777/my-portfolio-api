# My Portfolio API

API for my portfolio site.

## Random of the Day

The purpose of the project is to generate a random thing to amuse people during the work week. Currently it supports a random poem, fact, and painting.

The `generator` project is ran as an Amazon Web Services (AWS) Lambda at 12:00am every week day.

The `web` project is deployed onto AWS Elastic Beanstalk and returns saved data on AWS DynamoDB.

More details in the individual folders.

## Scripts

`./scripts/upload-poem.rb` is used to upload poems to DynamoDB, for ease.

Run `bundle exec rubocop` to run the RuboCop formatter on the project.