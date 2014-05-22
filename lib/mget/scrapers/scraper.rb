require_relative '../thread_pool'

module MangaGet
    class Scraper
        def initialize(pool_size)
            @thread_pool = Thread::Pool.new(pool_size)
        end

        def get_chapter(manga, n)
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapters(manga, list, threads)
            list.each do |n| 
                @thread_pool.schedule do
                    get_chapter(manga, n)
                end
            end
        end

        def zip_chapter(dir)
        end
    end
end
