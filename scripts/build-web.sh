#!/bin/bash   
cd web
rm ruby.zip
zip -r ruby Procfile config.ru Gemfile* app/*.rb