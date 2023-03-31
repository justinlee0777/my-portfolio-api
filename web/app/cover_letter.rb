# frozen_string_literal: true

class CoverLetter
  def initialize(bucket)
    @bucket = bucket

    @opening_object_name = 'opening'
    @ending_object_name = 'ending'
  end

  def get(company)
    content = get_object_contents @opening_object_name
    content += "\n\n"
    content += get_object_contents company
    content += "\n\n"
    content += get_object_contents @ending_object_name
  end

  private

  def get_object_contents(object_name)
    markdown_object = "#{object_name}.md"
    object = @bucket.object(markdown_object).get
    io = object['body']
    io.read
  end
end
