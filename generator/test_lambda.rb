require_relative './lambda_function'

p lambda_handler(event: ARGV[0], context: ARGV[1])
