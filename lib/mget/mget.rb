require_relative 'cli'
require_relative 'scrapers/manga_here'

include MangaGet

# parse options
options = CLI::parse_args

# create new manga_here scraper
s = MangaHereScraper.new(options[:manga], options[:threads], options)
s.get_chapters(options[:chapters])
