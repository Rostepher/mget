require_relative 'noez'

module MangaGet
    class MangaHere < Noez
        BASE_URL = "http://www.mangahere.co"

        class Series < Noez::Series
            CHAPTERS_FROM_SOURCE_XPATH = '//*[@class="detail_list"]//span/a'
            URL_FORMAT_STR = "/manga/%s"
        end

        class Chapter < Noez::Chapter
            CHAPTER_FROM_URL_REGEX = /\/c(?<chapter>\d+)/
            VOLUME_FROM_URL_REGEX = /\/v(?<volume>\d+)/
            PAGE_COUNT_FROM_SOURCE_REGEX = /var total_pages = (?<page_count>\d+)/
        end

        class Page < Noez::Page
            IMAGE_FROM_SOURCE_XPATH = '//*[@id="image"]'
        end
    end
end
