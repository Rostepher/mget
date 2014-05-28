require 'nokogiri'
require 'open-uri'
require 'fileutils'
require_relative 'scraper'

module MangaGet
    class MangaHereScraper < Scraper
        # base url for mangahere
        BASE_URL = 'http://mangahere.co'
        # xpath for image
        PAGE_IMAGE_XPATH = '//*[@id="image"]'
        # xpath for the select tag with links to each page in the chapter
        PAGE_SELECT_XPATH = '/html/body/section[1]/div[3]/span/select/option'
        # xpath for the list of all chapters on the series home
        CHAPTER_SELECT_XPATH = '//*[@id="main"]/article/div/div[2]/div[2]/ul[1]/li/span[1]/a'

        def initialize(manga, pool_size=4)
            super(manga, pool_size)
        end

        #
        # Returns true if the manga is available from mangahere and false
        # otherwise.
        #
        def manga_available?
            url = "#{BASE_URL}/manga/#{@manga}"
            page = Nokogiri::HTML(open(url))

            not page.xpath(CHAPTER_SELECT_XPATH).empty?
        end

        #
        # Returns true if the chapter given is available from mangahere and
        # false otherwise.
        #
        def chapter_available?(chapter)
            chapter = _pad_num(chapter)
            url = "#{BASE_URL}/manga/#{@manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))

            not page.xpath(PAGE_SELECT_XPATH).empty?
        end

        #
        # Scrapes mangahere for an array of links to each chapter in the
        # specified manga
        #
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

        #
        # Scrapes mangahere and returns an array of links to each page in the
        # chapter.
        #
        def get_page_links(chapter)
            chapter = _pad_num(chapter)
            url = "#{BASE_URL}/manga/#{@manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))

            pages = Array.new()
            page.xpath(PAGE_SELECT_XPATH).each do |match|
                pages << match[:value]
            end

            # return array of page links
            pages
        end

        #
        # Scrapes mangahere and downloads all images in a chapter then zips all
        # the images into a cbz archive.
        #
        def get_chapter(chapter)
            # check if the chapter is available
            unless chapter_available?(chapter)
                raise ChapterNotAvailableError.new(@manga, chapter, BASE_URL)
            end

            chapter = _pad_num(chapter)
            images = Array.new()

            puts "Getting #{@manga}/c#{chapter}"

            pages = get_page_links(chapter)
            pages.each do |url|
                page = Nokogiri::HTML(open(url))
                images << page.xpath(PAGE_IMAGE_XPATH)[0][:src]   
            end

            # make directory to hold chapter
            path = File.join(Dir.getwd, "#{@manga}/c#{chapter}")
            FileUtils.mkdir_p(path)

            # traverse each image and download
            (0...(images.length)).each do |i|
                name = (i + 1).to_s.rjust(3, '0')
                download_image(images[i], path, name)
            end
        end
    end
end
