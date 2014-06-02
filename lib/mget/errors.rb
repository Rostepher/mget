require_relative 'helpers'
require_relative 'string'

module MangaGet
    module Errors
        include MangaGet

        class MangaGetBaseError < StandardError
            def initialize(manga, source)
                super()
                @manga = Helpers::fmt_title(manga)
                @source = Helpers::fmt_title(source.to_s)
            end
        end

        class MangaLicensedError < MangaGetBaseError
            def message
                super() + ": \"#{@manga}\" is licensed, it is not available from #{@source}"
            end 
        end

        # Error class that means a manga/manhwa was not available.
        class MangaNotAvailableError < MangaGetBaseError
            def message
                super() + ": \"#{@manga}\" is not available from #{@source}"
            end
        end

        # Error class that means a chapter was not available.
        class ChapterNotAvailableError < MangaGetBaseError
            def initialize(manga, chapter, source)
                super(manga, source)
                @chapter = Helpers::pad(chapter)
            end

            def message
                super() + ": \"#{@manga}\":#{@chapter} is not available from #{@source}"
            end
        end
    end
end
