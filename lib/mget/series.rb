module MangaGet
    class Series
        class Chapter
            def initialize(title="", number)
                @title = title
                @number 
            end
        end

        def initialize(manga, scraper)
            @manga = manga
            @scraper = scraper
            @chapters = Array.new
        end

        def get_chapters(list)
            list.each do |n|
                @scraper.get_chapter(

        def get_current_chapter()
    end
end
