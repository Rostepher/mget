require 'zip'
require_relative '../thread_pool'

module MangaGet
    class Scraper
        IMAGE_NAME_REGEX = /(jpg|jpeg|png)/
        
        # constants
        BASE_URL = ''
        PAGE_IMAGE_XPATH = ''
        PAGE_SELECT_XPATH = ''
        CHAPTER_SELECT_XPATH = ''

        # getters
        attr_reader :manga

        def initialize(manga, pool_size=4)
            @manga = _sanitize_name(manga)
            @thread_pool = Thread::Pool.new(pool_size)
        end

        def manga_available?
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapter_links
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_page_links(chapter)
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapter(chapter)
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapters(list)
            list.each do |chapter| 
                @thread_pool.schedule do
                    get_chapter(chapter)
                end
            end
        end


        def download_image(url, path, name)
            match = IMAGE_NAME_REGEX.match(url)

            image = "#{File.join(path, name)}.#{match[0]}"
            open(image, 'wb') do |file|
                file << open(url).read 
            end
        end

        def zip_chapter(dir, zip_file_name)
            # change directory
            cur_dir = Dir.getwd
            Dir.chdir(dir)
            
            files = Dir.glob("*.(jpg|jpeg|png)")
            archive = File.join(dir, zip_file_name)
            p files
            Zip::File.open(archive, Zip::File::CREATE) do |zip_file|
                files.each do |file|
                    zip_file.add(file, dir + '/' + file)
                end

            end

            # change back to previous directory
            Dir.chdir(cur_dir)
        end
        
        # helpers
        private
        def _pad_chapter(chapter)
            chapter.to_s.rjust(3, '0')
        end
       
        def _sanitize_name(name)
            name.downcase.gsub(/\s/, '_')
        end
    end
end
