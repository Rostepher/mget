module MangaGet
    module Errors
        class MangaGetBaseError < StandardError
            def initialize(manga, source)
                @manga = capitalize_name(manga)
                @source = source
            end
            
            private

            def pad_num(num)
                num.to_s.rjust(3, '0')
            end

            def capitalize_name(name)
                name.split(/\s|\_|\.|\-/).map(&:capitalize).join(' ')
            end
        end
        
        class MangaNotAvailableError < MangaGetBaseError
            def to_s
                "\"#{@manga}\" is not available from #{@source}"
            end
        end

        class ChapterNotAvailableError < MangaGetBaseError
            def initialize(manga, chapter, source)
                super(manga, source)
                @chapter = pad_num(chapter)
            end

            def to_s
                "\"#{@manga}\":#{@chapter} is not available from #{@source}"
            end
        end
    end
end
