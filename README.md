I wanted a way to get covers of books in my Obsidian vault. I decided I wanted to import from Goodreads. Then it was just the matter of finding the RSS feed and scraping.

If you want to use this, you need the following variables in your `.env` file:

```
BOOKS_DIR=/Users/miharekar/Documents/Obsidian/books/
USER_ID=1234
RSS_KEY=5678
```

The first is self-explanatory, and the second and third one you get by going to _My Books_, and in the bottom row selecting _infinite scroll_, copying the RSS URL, and inspecting it for these two vars.

Then you can do something like

~~~
```dataview
TABLE WITHOUT ID
  "[![cover|150](" + image_url + ")](" + book_url + ")" + rating AS Cover,
  "[[" + file.path + "|" + title + "]]" AS Title
FROM "books" AND !"books/extra"
WHERE title
SORT file.ctime DESC
```
~~~

and have it render this:

![Screenshot](screenshot.png)
