# frozen_string_literal: true

class CoverLetter
  def initialize(bucket)
    @bucket = bucket

    @opening_object_name = 'opening'
    @ending_object_name = 'ending'
  end

  def get(company)
    validate_company company

    content = get_object_contents @opening_object_name
    content += "\n\n"
    content += get_object_contents company
    content += "\n\n"
    content += get_object_contents @ending_object_name
  end

  private

  def validate_company(company)
    raise CoverLetterValidationException, 'The company name is too long.' if company.length > 255

    pattern = /^[a-zA-Z0-9-]*$/

    return if company =~ pattern

    raise CoverLetterValidationException, "The company name does not match the pattern: #{pattern}"
  end

  def get_object_contents(object_name)
    markdown_object = "#{object_name}.md"
    object = @bucket.object(markdown_object).get
    io = object['body']
    io.read
  end
end

class CoverLetterValidationException < StandardError
  def initialize(message)
    super(message)
    @status_code = 400
  end

  attr_reader :status_code
end
