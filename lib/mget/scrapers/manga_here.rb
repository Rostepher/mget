require 'nokogiri'
require 'open-uri'

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

        #
        # Returns true if the manga is available from mangahere and false
        # otherwise.
        #
        def manga_available?
            url = "#{BASE_URL}/manga/#{@manga}"
            page = Nokogiri::HTML(open(url))

            !page.xpath(CHAPTER_SELECT_XPATH).empty?
        end

        #
        # Returns true if the chapter given is available from mangahere and
        # false otherwise.
        #
        def chapter_available?(chapter)
            chapter = pad_num(chapter)
            url = "#{BASE_URL}/manga/#{@manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))

            !page.xpath(PAGE_SELECT_XPATH).empty?
        end

        #
        # Scrapes mangahere for an array of chapter numbers. This is used
        # primarily to handle the awkward mini-chapters like 340.5.
        #
        def get_chapter_list
            urls = get_chapter_urls
            chapters = Array.new

            urls.each do |url|
                match = /\/c(\d{3}\.\d+|\d{3})/.match(url)[1]
                chapters << if float?(match)
                    match.to_f
                else
                    match.to_i
                end
            end

            # return array of chapter numbers
            chapters
        end

        #
        # Scrapes mangahere for an array of links to each chapter in @manga.
        # Currently unused, but leaving it for now.
        #
        def get_chapter_urls
            url = "#{BASE_URL}/manga/#{@manga}"
            page = Nokogiri::HTML(open(url))

            # get the list of chapter links
            chapters = Array.new
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
        def get_page_urls(chapter)
            chapter = pad_num(chapter)
            url = "#{BASE_URL}/manga/#{@manga}/c#{chapter}"
            page = Nokogiri::HTML(open(url))

            pages = Array.new
            page.xpath(PAGE_SELECT_XPATH).each do |match|
                pages << match[:value]
            end

            # return array of page links
            pages
        end

        #
        # Scrapes each page of a chapter for an image url and returns an array
        # of all the urls.
        #
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

        #
        # Scrapes mangahere and downloads all images in a chapter then zips all
        # the images into a cbz archive.
        #
        def get_chapter(chapter)
            # check if the chapter is available
            unless chapter_available?(chapter)
                raise ChapterNotAvailableError.new(@manga, chapter, @options[:source])
            end

            # verbose message
            verbose "Getting \"#{capitalize_name(@manga)}\":#{pad_num(chapter)}"
            
            images = get_image_urls(chapter)

            # make directory to hold chapter
            path = File.join(Dir.getwd, "#{@manga}/c#{pad_num(chapter)}")
            verbose "Making directory #{path}"
            FileUtils.mkdir_p(path)

            # traverse each image and download
            (0...(images.length)).each do |i|
                name = (i + 1).to_s.rjust(3, '0')
                download_image(images[i], path, name)
            end

            # zip if the zip option is set
            zip_chapter(chapter) if @options[:zip]
        end
    end
end
