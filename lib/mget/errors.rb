require_relative 'string'

module MangaGet
    module Errors
        include MangaGet

        class MangaLicensedError < StandardError
            def initialize(series)
                @series = series
                @site = @series.site.class::BASE_URL
            end

            def message
                manga = @series.name
                super() + ": \"#{manga}\" is licensed, it is not available from #{@site}"
            end
        end

        # Error class that means a manga/manhwa was not available.
        class MangaNotAvailableError < StandardError
            def initialize(series)
                @series = series
                @site = @series.site.class::BASE_URL
            end

            def message
                manga = @series.name
                super() + ": \"#{@series.name}\" is not available from #{@site}"
            end
        end

        # Error class that means a chapter was not available.
        class ChapterNotAvailableError < StandardError
            def initialize(chapter)
                @chapter = chapter
                @series = @chapter.series
                @site = @series.site.class::BASE_URL
            end

            def message
                manga = @series.name.titlecase
                super() + ": \"#{manga}\":#{@chapter.chpater} is not available from #{@site}"
            end
        end
    end
end
