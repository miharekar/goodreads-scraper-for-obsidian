# frozen_string_literal: true

require "bundler"
Bundler.require
require "dotenv/load"

GOODREADS_URL = "https://www.goodreads.com/review/list_rss"
def get_books_on(shelf)
  url = "#{GOODREADS_URL}/#{ENV['USER_ID']}?key=#{ENV['RSS_KEY']}&shelf=#{shelf}"
  doc = Nokogiri::XML(Faraday.get(url).body)
  doc.xpath("//item").map do |item|
    {
      "isbn" => item.xpath("isbn").text.to_i,
      "title" => item.xpath("title").text,
      "author" => item.xpath("author_name").text,
      "rating" => item.xpath("user_rating").text.to_i.times.map { "⭐️" }.join(" "),
      "image_url" => item.xpath("book_large_image_url").text,
      "book_url" => "https://www.goodreads.com/book/show/#{item.xpath('book_id').text}"
    }
  end
end

def update_books_on(shelf)
  books = get_books_on(shelf)
  books.each do |book|
    short_title = book["title"].split(":").first
    filename = "#{ENV['BOOKS_DIR']}#{short_title}.md"
    exists = File.exist?(filename)
    next unless exists

    content = File.read(filename)
    frontmatter = "#{book.to_yaml}---"
    content = if content.start_with?("---")
                content.sub(/^---.*?---/m, frontmatter)
              else
                "#{frontmatter}\n#{content}"
              end
    File.write(filename, content)
  end
end

puts "Updating books on 'read' shelf"
update_books_on("read")

puts "Updating books on 'import' shelf"
update_books_on("import")
