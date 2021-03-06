# frozen_string_literal: true

require './src/front_matter_parser.rb'

RSpec.describe 'insert_front_matters' do
  before(:all) do
    @html_dir = './spec/fixtures'
  end

  it '#parse_front_matter' do
    html_path = "#{@html_dir}/exported-note.html"
    front_matter = <<~HEREDOC
      ---
      layout: post
      title: 'test sepcial characters in evernote note export filename !@#$%^&*()_+{}[]\\|;',./:"<>? `~'
      ---
    HEREDOC
    expect(parse_front_matter_from_html(html_path)).to eq(front_matter)
  end

  it '#insert_front_matters' do
    # insert_front_matter(front_matter, file)
  end

  it '#insert_front_matters' do
    # insert_front_matters(dir)
  end
end
