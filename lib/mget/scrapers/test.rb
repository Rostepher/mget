require_relative 'manga_here'

MANGA = "One Piece"
PATH = "#{Dir.getwd}/#{MANGA}"

scraper = MangaGet::MangaHereScraper.new(MANGA, 4)
scraper.get_chapter(1)
scraper.zip_chapter("#{PATH}/c001", "#{MANGA}_c001.cbz")
