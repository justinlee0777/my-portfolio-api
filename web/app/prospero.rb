# frozen_string_literal: true

class Prospero
  def initialize(bucket)
    @bucket = bucket
  end

  def get(text_title, text_description, page_number, page_size)
    # Validate title
    validate_text_title text_title

    # Validate query parameters
    validate_get_query_parameters(page_number, page_size)

    # Get data
    object = @bucket.object(text_title).get
    io = object['body']
    text = io.read

    # Get pages
    mysql_client = get_sql_client

    starting_page = 1 + ((page_number - 1) * page_size)
    end_page = starting_page + (page_size - 1)

    results = mysql_client.query '' \
                                 'SELECT * FROM pages ' \
                                 'WHERE ' \
                                 "TextTitle = '#{text_title}' " \
                                 'AND ' \
                                 "Description = '#{text_description}' " \
                                 'AND ' \
                                 "PageNumber BETWEEN #{starting_page} AND #{end_page}"

    page_styles = mysql_client.query('SELECT * FROM page_styles ' \
                                     "WHERE TextTitle = '#{text_title}' AND Description = '#{text_description}'" \
                                     'LIMIT 1')
                              .first

    return nil unless page_styles

    total_size = mysql_client.query('SELECT COUNT(*) FROM pages ' \
                                    "WHERE TextTitle = '#{text_title}' AND Description = '#{text_description}'").first['COUNT(*)']

    content = results.map do |result|
      begin_index = result['BeginIndex']
      end_index = result['EndIndex']
      text[begin_index..end_index - 1]
    end

    JSON.generate({
                    value: {
                      pageStyles: {
                        width: page_styles['Width'],
                        height: page_styles['Height'],
                        computedFontSize: page_styles['ComputedFontSize'],
                        computedFontFamily: page_styles['ComputedFontFamily'],
                        lineHeight: page_styles['LineHeight'],
                        padding: {
                          top: page_styles['PaddingTop'],
                          right: page_styles['PaddingRight'],
                          bottom: page_styles['PaddingBottom'],
                          left: page_styles['PaddingLeft']
                        },
                        margin: {
                          top: page_styles['MarginTop'],
                          right: page_styles['MarginRight'],
                          bottom: page_styles['MarginBottom'],
                          left: page_styles['MarginLeft']
                        },
                        border: {
                          top: page_styles['BorderTop'],
                          right: page_styles['BorderRight'],
                          bottom: page_styles['BorderBottom'],
                          left: page_styles['BorderLeft']
                        }
                      },
                      content: content
                    },
                    page: {
                      pageNumber: page_number,
                      pageSize: page_size,
                      pages: (total_size.to_f / page_size).ceil,
                      totalSize: total_size
                    }
                  })
  end

  def update(text_title, text_description, text_data)
    validate_text_title text_title

    validate_text_data text_data

    object = @bucket.object text_title

    object.put({ body: text_data['text'] })

    mysql_client = get_sql_client

    page_styles = text_data['pageStyles']

    width = page_styles['width']
    height = page_styles['height']
    computed_font_size = page_styles['computedFontSize']
    computed_font_family = page_styles['computedFontFamily']
    line_height = page_styles['lineHeight']
    padding_top = page_styles['padding']['top']
    padding_right = page_styles['padding']['right']
    padding_bottom = page_styles['padding']['bottom']
    padding_left = page_styles['padding']['left']
    margin_top = page_styles['margin']['top']
    margin_right = page_styles['margin']['right']
    margin_bottom = page_styles['margin']['bottom']
    margin_left = page_styles['margin']['left']
    border_top = page_styles['border']['top']
    border_right = page_styles['border']['right']
    border_bottom = page_styles['border']['bottom']
    border_left = page_styles['border']['left']

    # update or create container style based on description
    mysql_client.query '' \
                       'REPLACE INTO page_styles ' \
                       'VALUES (' \
                       "#{width}," \
                       "#{height}," \
                       "'#{computed_font_size}'," \
                       "'#{computed_font_family}'," \
                       "#{padding_top}," \
                       "#{padding_right}," \
                       "#{padding_bottom}," \
                       "#{padding_left}," \
                       "#{margin_top}," \
                       "#{margin_right}," \
                       "#{margin_bottom}," \
                       "#{margin_left}," \
                       "#{border_top}," \
                       "#{border_right}," \
                       "#{border_bottom}," \
                       "#{border_left}," \
                       "'#{text_description}'," \
                       "'#{text_title}'," \
                       "#{line_height}" \
                       ')'

    # delete existing pages
    mysql_client.query "DELETE FROM pages WHERE TextTitle = '#{text_title}' AND Description = '#{text_description}'"

    page_values = []

    text_data['pages'].each_with_index do |page, index|
      page_values << "('#{text_title}',#{index + 1},#{page['beginIndex']},#{page['endIndex']},'#{text_description}')"
    end

    pages_query = "INSERT INTO pages VALUES#{page_values.join(', ')}"

    mysql_client.query pages_query
  end

  def validate_text_title(title)
    raise ProsperoValidationException, 'The text name is too long.' if title.length > 255

    # only allowing JSON files
    pattern = /^[a-zA-Z0-9-]+$/

    return if title =~ pattern

    raise ProsperoValidationException, "The text name does not match the pattern: #{pattern}"
  end

  # Data shape:
  # {
  #   "text": string,
  #   "pageStyles": {
  #      "width": number;
  #      "height": number;
  #      "computedFontSize": string;
  #      "computedFontFamily": string;
  #      "lineHeight": number;
  #      "padding": {
  #        "top": number;
  #        "right": number;
  #        "bottom": number;
  #        "left": number;
  #      };
  #      "margin": {
  #        "top": number;
  #        "right": number;
  #        "bottom": number;
  #        "left": number;
  #      };
  #      "border": {
  #        "top": number;
  #        "right": number;
  #        "bottom": number;
  #        "left": number;
  #      };
  #   },
  #   "pages": [
  #     // { "beginIndex", "endIndex" } array
  #   ]
  # }
  def validate_text_data(data)
    unless data['pageStyles'].instance_of? Hash
      raise ProsperoValidationException,
            '"pageStyles" should be an object.'
    end

    page_styles = data['pageStyles']

    unless page_styles['width'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.width" should be a number.'
    end
    unless page_styles['height'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.height" should be a number.'
    end

    unless page_styles['computedFontSize'].is_a? String
      raise ProsperoValidationException,
            '"pageStyles.computedFontSize" should be a string.'
    end
    unless page_styles['computedFontFamily'].is_a? String
      raise ProsperoValidationException,
            '"pageStyles.computedFontFamily" should be a string.'
    end

    unless page_styles['padding'].instance_of? Hash
      raise ProsperoValidationException,
            '"pageStyles.padding" should be an object.'
    end

    padding = page_styles['padding']

    unless padding['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.padding.top" should be a number.'
    end
    unless padding['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.padding.right" should be a number.'
    end
    unless padding['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.padding.bottom" should be a number.'
    end
    unless padding['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.padding.left" should be a number.'
    end

    unless page_styles['margin'].instance_of? Hash
      raise ProsperoValidationException,
            '"pageStyles.margin" should be an object.'
    end

    margin = page_styles['margin']

    unless margin['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.margin.top" should be a number.'
    end
    unless margin['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.margin.right" should be a number.'
    end
    unless margin['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.margin.bottom" should be a number.'
    end
    unless margin['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.margin.left" should be a number.'
    end

    unless page_styles['border'].instance_of? Hash
      raise ProsperoValidationException,
            '"pageStyles.border" should be an object.'
    end

    border = page_styles['border']

    unless border['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.border.top" should be a number.'
    end
    unless border['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.border.right" should be a number.'
    end
    unless border['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.border.bottom" should be a number.'
    end
    unless border['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"pageStyles.border.left" should be a number.'
    end

    unless data['pages'].instance_of? Array
      raise ProsperoValidationException,
            '"pages" should be an array.'
    end

    return if data['pages'].all? { |page| page['beginIndex'].is_a?(Numeric) && page['endIndex'].is_a?(Numeric) }

    raise ProsperoValidationException,
          '"pages" should contain numeric "beginIndex" and "endIndex".'
  end

  def validate_get_query_parameters(page_number, page_size)
    raise ProsperoValidationException, 'Query parameter "pageNumber" must be at least 1.' if page_number < 1

    return unless page_size < 1

    raise ProsperoValidationException, 'Query parameter "pageSize" must be at least 1.'
  end

  def get_sql_client
    Mysql2::Client.new(
      host: ENV.fetch('RDS_HOSTNAME', nil),
      username: ENV.fetch('RDS_USERNAME', nil),
      password: ENV.fetch('RDS_PASSWORD', nil),
      database: ENV.fetch('RDS_DB_NAME', nil),
      port: ENV.fetch('RDS_PORT', nil)
    )
  end
end

class ProsperoValidationException < StandardError
  def initialize(message)
    super(message)
    @status_code = 400
  end

  attr_reader :status_code
end
