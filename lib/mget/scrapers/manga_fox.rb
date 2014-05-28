require_relative 'scraper'

module MangaGet
    class MangaFoxScraper < Scraper
        include MangaGet

        BASE_URL = 'http://mangafox.me'
        PAGE_IMAGE_XPATH = '//*[@id="image"]'
        PAGE_SELECT_XPATH = '//*[@id="top_bar"]/div/div/select/option' # remember to remove the 0 option, it is comments
        CHAPTER_SELECT_XPATH = '//*[@id="chapters"]/ul/li//a'

        def initialize(manga, pool_size)
            super(manga, pool_size)
        end
    end
end
