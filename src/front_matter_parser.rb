# frozen_string_literal: true

require 'date'
require 'nokogiri'

# parse front matter from first line in markdown file in the format '2019-03-20-title'
# markdown: parse first line -> front matter -> insert to file
def parse_front_matter_from_markdown(md_path)
  first_line = File.open(md_path, &:readline)
  filename = /([0-9]{4}-[0-9]{2}-[0-9]{2}-)?(.*)/.match(first_line)[2]
  date_matches = /([0-9]{4}-[0-9]{2}-[0-9]{2})-*/.match(first_line)

  if date_matches.nil?
    <<~FRONT_MATTER
      ---
      title: #{filename}
      layout: post
      date: '#{Time.now.strftime('%Y-%m-%d')}'
      categories: draft
      published: false
      ---
    FRONT_MATTER
  else
    <<~FRONT_MATTER
      ---
      title: #{filename}
      layout: post
      date: '#{date_matches[1]}'
      categories: draft
      published: false
      ---
    FRONT_MATTER
  end
end

def parse_created_date_from_html(html_path)
  html_page = Nokogiri::HTML(open(html_path))
  keywords_meta_elements = html_page.css('meta[name=created]')
  if keywords_meta_elements.length > 0
    created_date = keywords_meta_elements.first.attributes['content']
                                         .value.split(', ').first
    puts "|#{html_path}|#{DateTime.parse(created_date).strftime('%Y-%m-%d')}|"
  end
end

# parse front matter from name meta attribute in html file
# html: parse meta data -> front matter -> insert to file
def parse_front_matter_from_html(html_path)
  html_page = Nokogiri::HTML(open(html_path))
  keywords_meta_elements = html_page.css('meta[name=keywords]')

  if keywords_meta_elements.empty?
    <<~FRONT_MATTER
      ---
      layout: post
      title: '#{html_page.title}'
      ---
    FRONT_MATTER
  else
    keywords = keywords_meta_elements.first.attributes['content']
                                     .value.split(', ')
    <<~FRONT_MATTER
      ---
      layout: post
      title: '#{html_page.title}'
      categories: #{keywords.join(' ')}
      ---
    FRONT_MATTER
  end
end

def insert_front_matter(front_matter, file)
  File.open(file, 'r+') do |f|
    lines = f.each_line.to_a
    lines.unshift(front_matter)
    f.rewind
    f.write(lines.join)
  end
end

def delete_original_title(file_path)
  `sed '8d' "#{file_path}" > tmpfile; mv tmpfile "#{file_path}"`
end

# insert front matter to html and markdown files.
def insert_front_matters(dir)
  sanitized_file_paths = Dir["#{dir}/*"].reject do |file_path|
    File.open(file_path, &:readline) == "---\n"
  end

  sanitized_file_paths.each do |file_path|
    case File.extname(file_path)
    when '.html'
      front_matter = parse_front_matter_from_html(file_path)
      insert_front_matter(front_matter, file_path)
    when '.md'
      front_matter = parse_front_matter_from_markdown(file_path)
      insert_front_matter(front_matter, file_path)
      delete_original_title(file_path)
    end
  end
end

def print_created_date_from_html_in_dir(dir)
  Dir["#{dir}/*.html"].each do |file_path|
    parse_created_date_from_html(file_path)
  end
end
