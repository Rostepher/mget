require 'nokogiri'
require 'open-uri'
require 'fileutils'
require_relative 'scraper'

module MangaGet
    class MangaHereScraper < Scraper
        # constants
        BASE_URL = 'http://mangahere.co'
        IMAGE_NAME_REGEX = /(jpg|jpeg|png)/
        PAGE_IMAGE_XPATH = '//*[@id="image"]'
        PAGE_SELECT_XPATH = '/html/body/section[1]/div[3]/span/select/option'
        CHAPTER_SELECT_XPATH = '//*[@id="main"]/article/div/div[2]/div[2]/ul[1]/li/span[1]/a'

        def initialize(manga, pool_size=4)
            super(manga, pool_size)
        end

        def manga_available?
            url = "#{BASE_URL}/manga/#{@manga}"
            page = Nokogiri::HTML(open(url))

            page.xpath(CHAPTER_SELECT_XPATH).nil?
        end

        def get_chapter_links
            url = "#{BASE_URL}/manga/#{@manga}"
            p url
            page = Nokogiri::HTML(open(url))

            # get the list of chapter links
            chapters = Array.new()
            page.xpath(CHAPTER_SELECT_XPATH).each do |match|
                chapters << match[:href]
            end

            # return array of chapter links
            chapters
        end

        def get_page_links(chapter)
            chapter = _pad_chapter(chapter)
            url = "#{BASE_URL}/manga/#{@manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))

            pages = Array.new()
            page.xpath(PAGE_SELECT_XPATH).each do |match|
                pages << match[:value]
            end

            # return array of page links
            pages
        end

        def get_chapter(chapter)
            # check if manga is available
            if not manga_available?
                puts "#{@manga.gsub('_', ' ').capitalize} is not available from #{BASE_URL}" 
                return nil
            end

            chapter = _pad_chapter(chapter)
            images = Array.new()
            
            pages = get_page_links(chapter)
            pages.each do |url|
                page = Nokogiri::HTML(open(url))
                images << page.xpath(PAGE_IMAGE_XPATH)[0][:src]   
            end

            # make directory to hold chapter
            path = "#{Dir.getwd}/#{@manga}/c#{chapter}"
            FileUtils.mkdir_p(path)

            # traverse each image and download
            (0...(images.length)).each do |i|
                name = (i + 1).to_s.rjust(3, '0')
                download_image(images[i], path, name)
            end
        end
    end
end
