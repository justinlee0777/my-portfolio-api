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

    container_styles = mysql_client.query('SELECT * FROM container_styles ' \
                                          "WHERE TextTitle = '#{text_title}' AND Description = '#{text_description}'" \
                                          'LIMIT 1')
                                   .first

    return nil unless container_styles

    total_size = mysql_client.query('SELECT COUNT(*) FROM pages ' \
                                    "WHERE TextTitle = '#{text_title}' AND Description = '#{text_description}'").first['COUNT(*)']

    content = results.map do |result|
      begin_index = result['BeginIndex']
      end_index = result['EndIndex']
      text[begin_index..end_index - 1]
    end

    JSON.generate({
                    value: {
                      containerStyles: {
                        width: container_styles['Width'],
                        height: container_styles['Height'],
                        computedFontSize: container_styles['ComputedFontSize'],
                        computedFontFamily: container_styles['ComputedFontFamily'],
                        lineHeight: container_styles['LineHeight'],
                        padding: {
                          top: container_styles['PaddingTop'],
                          right: container_styles['PaddingRight'],
                          bottom: container_styles['PaddingBottom'],
                          left: container_styles['PaddingLeft']
                        },
                        margin: {
                          top: container_styles['MarginTop'],
                          right: container_styles['MarginRight'],
                          bottom: container_styles['MarginBottom'],
                          left: container_styles['MarginLeft']
                        },
                        border: {
                          top: container_styles['BorderTop'],
                          right: container_styles['BorderRight'],
                          bottom: container_styles['BorderBottom'],
                          left: container_styles['BorderLeft']
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

    container_styles = text_data['containerStyles']

    width = container_styles['width']
    height = container_styles['height']
    computed_font_size = container_styles['computedFontSize']
    computed_font_family = container_styles['computedFontFamily']
    line_height = container_styles['lineHeight']
    padding_top = container_styles['padding']['top']
    padding_right = container_styles['padding']['right']
    padding_bottom = container_styles['padding']['bottom']
    padding_left = container_styles['padding']['left']
    margin_top = container_styles['margin']['top']
    margin_right = container_styles['margin']['right']
    margin_bottom = container_styles['margin']['bottom']
    margin_left = container_styles['margin']['left']
    border_top = container_styles['border']['top']
    border_right = container_styles['border']['right']
    border_bottom = container_styles['border']['bottom']
    border_left = container_styles['border']['left']

    # update or create container style based on description
    mysql_client.query '' \
                       'REPLACE INTO container_styles ' \
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
  #   "containerStyles": {
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
    unless data['containerStyles'].instance_of? Hash
      raise ProsperoValidationException,
            '"containerStyles" should be an object.'
    end

    container_styles = data['containerStyles']

    unless container_styles['width'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.width" should be a number.'
    end
    unless container_styles['height'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.height" should be a number.'
    end

    unless container_styles['computedFontSize'].is_a? String
      raise ProsperoValidationException,
            '"containerStyles.computedFontSize" should be a string.'
    end
    unless container_styles['computedFontFamily'].is_a? String
      raise ProsperoValidationException,
            '"containerStyles.computedFontFamily" should be a string.'
    end

    unless container_styles['padding'].instance_of? Hash
      raise ProsperoValidationException,
            '"containerStyles.padding" should be an object.'
    end

    padding = container_styles['padding']

    unless padding['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.padding.top" should be a number.'
    end
    unless padding['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.padding.right" should be a number.'
    end
    unless padding['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.padding.bottom" should be a number.'
    end
    unless padding['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.padding.left" should be a number.'
    end

    unless container_styles['margin'].instance_of? Hash
      raise ProsperoValidationException,
            '"containerStyles.margin" should be an object.'
    end

    margin = container_styles['margin']

    unless margin['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.margin.top" should be a number.'
    end
    unless margin['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.margin.right" should be a number.'
    end
    unless margin['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.margin.bottom" should be a number.'
    end
    unless margin['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.margin.left" should be a number.'
    end

    unless container_styles['border'].instance_of? Hash
      raise ProsperoValidationException,
            '"containerStyles.border" should be an object.'
    end

    border = container_styles['border']

    unless border['top'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.border.top" should be a number.'
    end
    unless border['right'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.border.right" should be a number.'
    end
    unless border['bottom'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.border.bottom" should be a number.'
    end
    unless border['left'].is_a? Numeric
      raise ProsperoValidationException,
            '"containerStyles.border.left" should be a number.'
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
