# frozen_string_literal: true

require "bundler"
Bundler.require
require "dotenv/load"

GOODREADS_URL = "https://www.goodreads.com/review/list_rss"
def get_books_on(shelf)
  url = "#{GOODREADS_URL}/#{ENV['USER_ID']}?key=#{ENV['RSS_KEY']}&shelf=#{shelf}"
  doc = Nokogiri::XML(Faraday.get(url).body)
  doc.xpath("//item").map do |item|
    book = {}
    read_at = item.xpath("user_read_at").text
    book["read_at"] = DateTime.parse(item.xpath("user_read_at").text).iso8601 unless read_at.blank?
    book.merge({
                 "isbn" => item.xpath("isbn").text.to_i,
                 "title" => item.xpath("title").text,
                 "author" => item.xpath("author_name").text,
                 "rating" => item.xpath("user_rating").text.to_i.times.map { "⭐️" }.join,
                 "image_url" => item.xpath("book_large_image_url").text,
                 "book_url" => "https://www.goodreads.com/book/show/#{item.xpath('book_id').text}"
               })
  end
end

def update_books_on(shelf)
  books = get_books_on(shelf)
  books.each do |book|
    short_title = book["title"].split(":").first
    filename = "#{ENV['BOOKS_DIR']}#{short_title}.md"
    if File.exist?(filename)
      File.write(filename, content_with_frontmatter(File.read(filename), book))
    else
      puts "File #{filename} does not exist."
      # puts "Do you want to create it?"
      # %w[yes y].include?(gets.chomp.downcase) ? File.write(filename, content_with_frontmatter("", book)) : next
    end
  end
end

def content_with_frontmatter(content, book)
  content = "---\n---\n#{content}" unless content.start_with?("---")
  data = YAML.safe_load(content) || {}
  data["goodreads"] = (data["goodreads"] || {}).merge(book)
  frontmatter = "#{data.to_yaml}---"
  content.sub(/^---.*?---/m, frontmatter)
end

puts "Updating books on 'read' shelf"
update_books_on("read")

puts "Updating books on 'import' shelf"
update_books_on("import")
