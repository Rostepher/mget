require_relative 'manga_here'

MANGA = "Hunter X Hunter"
CHAPTERS = [340.5, 1]
OPTS_HASH = { verbose: true, zip:true }

scraper = MangaGet::MangaHereScraper.new(MANGA, 4, OPTS_HASH)
scraper.get_chapters(CHAPTERS)
