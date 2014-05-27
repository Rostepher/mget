require_relative 'manga_here.rb'

MANGA = "feng_shen_ji"
PATH = "#{Dir.getwd}/#{MANGA}"

scraper = MangaGet::MangaHereScraper.new(4)
scraper.get_chapter(MANGA, 1)
scraper.zip_chapter("#{PATH}/c001", "#{MANGA}_c001.cbz")
