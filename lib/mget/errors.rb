module MangaGet
    module Errors
        class MangaNotAvailableError < StandardError
            attr_reader :manga
            
            def initialize(manga, source)
                @manga = manga.capitalize.gsub('_', ' ')
                @source = source
            end

            def to_s
                "#{@manga} is not available from #{@source}"
            end
        end

        class ChapterNotAvailableError < StandardError
            attr_reader :manga, :chapter

            def initialize(manga, chapter, source)
                @manga = manga.capitalize.gsub('_', ' ')
                @chapter = chapter.to_s.rjust(3, '0')
                @source = source
            end

            def to_s
                "#{@manga}: chapter #{@chapter} is not available from #{@source}"
            end
        end
    end
end
