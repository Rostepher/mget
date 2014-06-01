require_relative 'helpers'
require_relative 'string'

module MangaGet
    module Errors
        include MangaGet::Helpers

        # Error class that means a manga/manhwa was not available.
        class MangaNotAvailableError < StandardError
            def initialize(manga, source)
                super()
                @manga = manga.titlecase
                @source = source.to_s.titlecase
            end
            
            def message
                super + "\"#{@manga}\" is not available from #{@source}"
            end
        end

        # Error class that means a chapter was not available.
        class ChapterNotAvailableError < StandardError
            def initialize(manga, chapter, source)
                super()
                @manga = manga.titlecase
                @chapter = pad(chapter)
                @source = source.to_s.titlecase
            end

            def message
                super + "\"#{@manga}\":#{@chapter} is not available from #{@source}"
            end
        end
    end
end
