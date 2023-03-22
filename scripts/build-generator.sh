#!/bin/bash
cd generator
bundle config set --local path vendor/bundle
bundle install
rm function.zip
zip -r function lambda_function.rb **/*.rb vendor