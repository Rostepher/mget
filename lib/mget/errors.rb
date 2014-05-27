module MangaGet
    module Errors
        class MangaNotAvailableError < StandardError
            attr_reader :manga
            
            def initialize(manga, source)
                @manga = manga.capitalize.gsub('_', ' ')
                @source = source
            end

            def to_s
                "#{@manga} not available from #{@source}"
            end
        end
    end
end
