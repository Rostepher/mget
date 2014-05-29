require_relative 'manga_here'

MANGA = "Feng Shen Ji"
CHAPTERS = (1..2).to_a << 108
OPTS_HASH = { verbose: true, zip:true }

scraper = MangaGet::MangaHereScraper.new(MANGA, 4, OPTS_HASH)
scraper.get_chapters(CHAPTERS)
