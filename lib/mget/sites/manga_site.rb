require 'nokogiri'
require 'open-uri'

require_relative '../image'
require_relative '../url'

module MangaGet
    class MangaSite
        BASE_URL = nil

        # Returns an instance of {Series} using the name given.
        #
        # @params name [String] name of manga series
        # @returns [Series] manga series
        def series(name)
            self.class::Series.new(name, self)
        end

        class Series
            CHAPTERS_FROM_SOURCE_XPATH = nil
            URL_FORMAT_STR = nil

            attr_reader :name, :site

            def initialize(name, site)
                @name = name
                @site = site
                @cache = Hash.new
            end

            def sanitized_name
                raise NotImplementedError
            end

            def available?
                raise NotImplementedError
            end

            def licensed?
                raise NotImplementedError
            end

            # Returns the manga series url using the URL_FORMAT_STR of the
            # objects class.
            #
            # @returns [String] formatted manga series url
            def url
                formated_str = self.class::URL_FORMAT_STR % sanitized_name
                URL::join(@site.class::BASE_URL, formated_str)
            end

            def chapters
                raise NotImplementedError
            end

            private

            # Clears the current cache hash.
            def clear_cache
                @cache = Hash.new
            end
        end

        class Chapter
            VOLUME_FROM_URL_REGEX = nil
            CHAPTER_FROM_URL_REGEX = nil
            PAGE_COUNT_FROM_SOURCE_REGEX = nil

            attr_reader :series, :url

            def initialize(series, url)
                @series = series
                @url = url
                @cache = Hash.new
            end

            def available?
                raise NotImplementedError
            end

            # Returns the volume number from the url. If there is not volume
            # then it will return nil. It will cache the value and return the
            # cached value upon future calls, unless the refresh arg is true.
            #
            # @params refresh [true, false] force the value to be refreshed
            # @returns [String, nil] volume number as a string or nil
            def volume(refresh=false)
                # return cached value if it exists or refresh is false
                if @cache.has_key? :volume && !refresh
                    return @cache[:volume]
                end

                match = self.class::VOLUME_FROM_URL_REGEX.match(@url)

                if match.nil?
                    nil
                else
                    @cache[:volume] = match[:volume]
                end
            end

            # Returns the chapter number from the url. If there is no chapter
            # then it will return nil. It will cache the value and return the
            # cached value upon future calls, unless the refresh arg is true.
            #
            # @params refresh [true, false] force the value to be refreshed
            # @returns [String, nil] chapter number as a string
            def chapter(refresh=false)
                # return cached value if it exists or refresh is false
                if @cache.has_key? :chapter && !refresh
                    return @cache[:chapter]
                end

                match = self.class::CHAPTER_FROM_URL_REGEX.match(@url)

                if match.nil?
                    nil
                else
                    @cache[:chapter] = match[:chapter]
                end
            end

            # Returns the title of the chapter if it exists, otherwise nil.
            # This method caches the result and will return the cached result
            # unless the refresh arg is true.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [String, nil] title of the chapter or nil
            def title(refresh=false)
                if @cache.has_key? :title && !refresh
                    return @cache[:title]
                end

                #TODO
                raise NotImplementedError
            end

            # Returns the total page count of a chapter scraped from the source
            # page. If there is no match from the source it will return nil. It
            # will cache the value and return the cached value upon future
            # calls, unless the refresh arg is true.
            #
            # @params refresh [true, false] force the value to be refreshed
            # @returns [Integer, nil] total page count or nil
            def page_count(refresh=false)
                # return cached value if it exists or refresh if false
                if @cache.has_key? :page_count && !refresh
                    return @cache[:page_count]
                end

                page_source = open(@url, &:read)
                match = self.class::PAGE_COUNT_FROM_SOURCE_REGEX.match(page_source)

                # expect the regex to capture 'page_count'
                if match.nil?
                    nil
                else
                    @cache[:page_count] = match[:page_count].to_i
                end
            end

            def pages
                raise NotImplementedError
            end

            private

            # Clears the current cache hash.
            def clear_cache
                @cache = Hash.new
            end
        end

        class Page
            IMAGE_FROM_SOURCE_XPATH = nil

            attr_reader :chapter, :url, :number

            def initialize(chapter, url, number)
                @chapter = chapter
                @url = url
                @number = number
            end

            # Returns Image object of the image of the page.
            #
            # @returns [MangaGet::Image] image
            def image
                page = Nokogiri::HTML(open(@url))
                match = page.xpath(self.class::IMAGE_FROM_SOURCE_XPATH)

                if match.nil?
                    nil
                else
                    Image.new(match.first[:src])
                end
            end
        end
    end
end
