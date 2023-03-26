# Random of the Day generator

The code loads data for poems, facts, paintings etc. and then uploads the chosen data to a database. Sources are either private or from a variety of public APIs.

Install dependencies first:
```
bundle install
```

Then run `ruby lambda_function.rb`, or `ruby test_lambda.rb` which calls the former internally and prints out the results in console.