require 'nokogiri'
require 'open-uri'

require_relative 'scraper'
require_relative '../string'

module MangaGet
    
    # Subclass of {MangaGet::Scraper Scraper} that targets mangapanda.com
    class MangaPandaScraper < Scraper
        
        # base url for mangahere
        BASE_URL = 'http://mangapanda.com'
        # delimeter used by mangapanda
        NAME_DELIM = '-'
        
        # xpath for image
        PAGE_IMAGE_XPATH = '//*[@id="img"]'
        # xpath for the tag holding the last page number
        PAGE_MAX_XPATH = '//*[@id="selectpage"]/text()'
        # xpath for the list of all chapters on the series home
        CHAPTER_SELECT_XPATH = '//*[@id="listing"]/tbody/tr/td/a'
        # xpath to the warning put on mangapanda pages for licensed manga
        MANGA_LICENSED_XPATH = '' 

        # regex to match chapter number in url
        CHAPTER_NUMBER_REGEX = /\/c(\d{3}\.{0,1}\d*)/

        private

        # Returns a string of the base mana url.
        #
        # @returns [String] base manga url
        def manga_url
            "#{BASE_URL}/#{@manga}"
        end

        # Returns the path to the directory for the given chapter.
        #
        # @param chapter [Integer, Float] chapter
        # @returns [String] path to chapter directory
        def chapter_path(chapter)
            File.join(@temp_dir, "c#{Helpers::pad(chapter)}")
        end

        # Returns true if the manga is available from mangahere and false
        # otherwise.
        #
        # @returns [true, flase] if the manga is available from mangahere.co
        def manga_available?
            return false if licensed?
            !@chapters.empty?
        end

        # Returns true if the chapter given is available from mangahere and
        # false otherwise.
        #
        # @param chapter [Integer, Float] chapter number
        # @returns [true, false] if chapter is available
        def chapter_available?(chapter)
            return false if licensed?
            @chapters.key?(chapter)
        end

        # Returns true if the manga is licensed, meaning no chapters are
        # available from mangafox.me
        # 
        # @returns [true, false] if the manga is licensed
        def licensed?
            #page = Nokogiri::HTML(open(manga_url))

            # mangapanda.com does not care about licenses...
            # as far as I can tell
            false
        end

        # Scrapes mangahere for a hash, with each key being the chapter number
        # and the value is the url for that chapter. This is used primarily to
        # handle the awkward mini-chapters like 340.5.
        #
        # @returns [Hash{(Integer, Float) => String}] a hash of each chapter url
        #   related to a key of the chapter number
        def get_chapters_hash
            urls = get_chapter_urls
            chapters = Hash.new

            urls.each do |url|
                match = CHAPTER_NUMBER_REGEX.match(url)[1].to_n
                chapters[match] = url if !match.nil?
            end

            # return hash of chapter numbers
            chapters
        end

        # Scrapes mangahere for an array of links to each chapter in @manga.
        #
        # @returns [Array<String>] an array of urls for each chapter of a manga
        def get_chapter_urls
            page = Nokogiri::HTML(open(manga_url))

            # get the list of chapter links
            chapters = Array.new
            page.xpath(CHAPTER_SELECT_XPATH).each do |match|
                chapters << match[:href]
            end

            # return array of chapter links
            chapters.sort!
        end

        # Scrapes mangahere and returns an array of links to each page in the
        # chapter.
        #
        # @param chapters [Integer, Float] the chapter number
        # @returns [Array<String>] an array of urls for each page in a chapter
        def get_page_urls(chapter)
            url = @chapters[chapter]
            page = Nokogiri::HTML(open(url))

            # find the page max
            elem = page.xpath(PAGE_MAX_XPATH)
            max = elem.to_s.strip!
            max = /(\d+)/.match(max)[1].to_i

            # step through each page and sub in page number to url
            pages = Array.new
            1.upto(max) do |n|
                link = url.gsub(/\/\d+\.html/, "/#{n}.html")
                pages << link
            end

            # return array of page links
            pages
        end

        # Scrapes each page of a chapter for an image url and returns an array
        # of all the urls.
        #
        # @param chapter [Integer, Float] the chapter number
        # @returns [Array<String>] an array of urls for each image in a chapter
        def get_image_urls(chapter)
            images = Array.new

            pages = get_page_urls(chapter)
            pages.each do |url|
                page = Nokogiri::HTML(open(url))
                images << page.xpath(PAGE_IMAGE_XPATH)[0][:src]
            end
       
            # return array of image links
            images
        end
    end
end
