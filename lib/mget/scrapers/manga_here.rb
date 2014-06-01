require 'nokogiri'
require 'open-uri'

require_relative 'scraper'
require_relative '../string'

module MangaGet
    
    # Subclass of {MangaGet::Scraper Scraper} that targets mangahere.co
    class MangaHereScraper < Scraper

        # base url for mangahere
        BASE_URL = 'http://mangahere.co'

        # xpath for image
        PAGE_IMAGE_XPATH = '//*[@id="image"]'
        # xpath for the select tag with links to each page in the chapter
        PAGE_SELECT_XPATH = '/html/body/section[1]/div[3]/span/select/option'
        # xpath for the list of all chapters on the series home
        CHAPTER_SELECT_XPATH = '//*[@id="main"]/article/div/div[2]/div[2]/ul[1]/li/span[1]/a'
        
        # regex to match chapter number in url
        CHAPTER_NUMBER_REGEX = /\/c(\d{3}\.{0,1}\d*)/

        # Returns true if the manga is available from mangahere and false
        # otherwise.
        #
        # @returns [true, flase] if the manga is available from mangahere.co
        def manga_available?
            !@chapters.empty?
        end

        # Returns true if the chapter given is available from mangahere and
        # false otherwise.
        #
        # @param chapter [Integer, Float] chapter number
        # @returns [true, false] if chapter is available
        def chapter_available?(chapter)
            @chapters.key?(chapter)
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
                match = (CHAPTER_NUMBER_REGEX.match(url)[1]).to_n
                chapters[match] = url if !match.nil?
            end

            # return hash of chapter numbers
            chapters
        end

        # Scrapes mangahere for an array of links to each chapter in @manga.
        #
        # @returns [Array<String>] an array of urls for each chapter of a manga
        def get_chapter_urls
            url = "#{BASE_URL}/manga/#{@manga}"
            page = Nokogiri::HTML(open(url))

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

            pages = Array.new
            page.xpath(PAGE_SELECT_XPATH).each do |match|
                pages << match[:value]
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

        # Scrapes mangahere and downloads all images in a chapter then zips all
        # the images into a cbz archive.
        #
        # @param chapter [Integer, Float] the chapter number
        def get_chapter(chapter)
            # check if the chapter is available
            if !chapter_available?(chapter)
                raise ChapterNotAvailableError.new(@manga, chapter, @options[:source])
            end

            p Helpers::pad(chapter)

            # verbose message
            verbose "Getting \"#{@manga.titlecase}\":#{Helpers::pad(chapter)}"
            
            # make directory to hold chapter
            path = File.join(@temp_dir, "c#{Helpers::pad(chapter)}")
            verbose "Making directory #{path}"
            FileUtils.mkdir_p(path)

            # traverse each image and download
            images = get_image_urls(chapter)
            0.upto(images.length) do |i|
                name = Helpers::pad(i + 1)
                download_image(images[i], path, name)
            end

            # zip if the zip option is set
            zip_chapter(chapter) if @options[:zip]
        end
    end
end
