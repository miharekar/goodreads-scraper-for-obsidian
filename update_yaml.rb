# frozen_string_literal: true

require "bundler"
Bundler.require
require "active_support/core_ext/object/blank"
require "dotenv/load"

def unnest_hash(hash)
  hash.each_with_object({}) do |(k, v), h|
    if v.is_a?(Hash)
      k = k == "goodreads" ? "gr" : k
      v.each do |k2, v2|
        h["#{k}_#{k2}"] = v2
      end
    else
      h[k] = v
    end
  end
end

def replace_frontmatter_in_content(content)
  content = "---\n---\n#{content}" unless content.start_with?("---")
  data = YAML.safe_load(content) || {}
  frontmatter = "#{unnest_hash(data).to_yaml}---"
  content.sub(/^---.*?---/m, frontmatter)
end

files = Dir.glob("#{ENV.fetch('BOOKS_DIR', nil)}*.md")
files.each do |file|
  content = File.read(file)
  File.write(file, replace_frontmatter_in_content(content))
end
