require_relative 'manga_here'

MANGA = "Feng Shen Ji"
CHAPTERS = [1, 2, 3, 108]

scraper = MangaGet::MangaHereScraper.new(MANGA, 4)
scraper.get_chapters(CHAPTERS)
#CHAPTERS.each { |c| scraper.zip_chapter(c) }
