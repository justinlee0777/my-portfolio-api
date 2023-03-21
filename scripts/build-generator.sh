#!/bin/bash
cd generator
bundle config set --local path 'vendor/bundle'
bundle install
zip -r function lambda_function.rb vendor