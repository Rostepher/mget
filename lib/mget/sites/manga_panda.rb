require_relative 'aftv'

module MangaGet
    class MangaPanda < Aftv
        BASE_URL = "http://www.mangapanda.com"

        class Series < Aftv::Series
            CHAPTERS_FROM_SOURCE_XPATH = '//*[@id="listing"]//a'
            URL_FORMAT_STR = "/%s"
        end

        class Chapter < Aftv::Chapter
            # mangapanda does't put volume in url
            VOLUME_FROM_URL_REGEX = nil
            CHAPTER_FROM_URL_REGEX = /\/(|chapter\-)(?<chapter>\d+)($|\.html$)/
            PAGE_COUNT_FROM_SOURCE_REGEX = /of (?<page_count>\d+)/
        end

        class Page < Aftv::Page
            IMAGE_FROM_SOURCE_XPATH = '//*[@id="img"]'
        end
    end
end
