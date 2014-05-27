require_relative 'manga_here'

MANGA = "Feng Shen Ji"
CHAPTER = 1

scraper = MangaGet::MangaHereScraper.new(MANGA, 4)
scraper.get_chapter(CHAPTER)
scraper.zip_chapter(CHAPTER)
