require 'nokogiri'
require 'open-uri'
require_relative 'scraper'

module MangaGet
    class MangaHereScraper < Scraper
        BASE_URL = "https://mangahere.co"
        CHAPTER_PATTERN = /\/c(\d+)/
        PAGE_IMG_XPATH = "//section[@class='read_img']//img"

        def initialize(pool_size)
            super(pool_size)
        end

        def get_chapter(manga, chapter)
            
            
            # open the first page of the chapter
            url = "#{BASE_URL}/manga/#{manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))
            

        end

        def get_series_url(manga)
            url = "#{BASE_URL}/manga/c
    end
end
