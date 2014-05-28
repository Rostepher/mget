require 'zip'
require_relative '../errors'
require_relative '../thread_pool'

module MangaGet
    class Scraper
        include MangaGet
        include MangaGet::Errors

        # regex defining what image types are used
        IMAGE_TYPE_REGEX = /(jpg|jpeg|png)/
        
        # constants to define in subclasses
        BASE_URL = ''
        PAGE_IMAGE_XPATH = ''
        PAGE_SELECT_XPATH = ''
        CHAPTER_SELECT_XPATH = ''

        # getters
        attr_reader :manga

        def initialize(manga, pool_size=4)
            @manga = _sanitize_name(manga)
            @thread_pool = ThreadPool.new(pool_size)
        end

        def manga_available?
            # reimplement in child classes
            raise NotImplementedError
        end

        def chapter_available?
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

        #
        # Downloads all chapters in a given list, must only contain Integers.
        # Each chapter is assigned as a task to a thread in the pool, thus
        # allowing multiple chapters to be downloaded at once.
        #
        def get_chapters(list)
            unless manga_available?
                raise MangaNotAvailableError.new(@manga, BASE_URL)
            end

            list.each do |chapter| 
                @thread_pool.schedule do
                    begin
                        get_chapter(chapter)
                    rescue ChapterNotAvailableError => e
                        puts e.to_s
                    end
                end
            end

            # wait for threads to finish
            @thread_pool.join
        end

        #
        # Helper method to download images from urls to the given path.
        #
        def download_image(url, path, name)
            match = IMAGE_TYPE_REGEX.match(url)

            image = "#{File.join(path, name)}.#{match[0]}"
            open(image, 'wb') do |file|
                file << open(url).read 
            end
        end

        #
        # Zips a directory of images into a cbz archive with the the name.
        # This method assumes the existence of the chapter and directory
        # structure @manga/c### in the current working directory.
        #
        def zip_chapter(chapter)
            chapter = _pad_num(chapter)

            path = File.join(Dir.getwd, "#{@manga}/c#{chapter}")
            zip_name = "#{@manga}.c#{chapter}.cbz"
            file_regex = /\d{3}\.(jpg|jpeg|png)/i
        
            zip_dir(path, zip_name, file_regex)
        end
       
        #
        # Helper method to zip all files in a directory that match the given
        # file_regex.
        #
        def zip_dir(path, zip_name, file_regex)
            # change directory to target
            cur_dir = Dir.getwd
            Dir.chdir(path)

            # glob files to zip
            files = Dir['*'].select { |f| f =~ file_regex }.sort!

            # zip files
            Zip::File.open(zip_name, Zip::File::CREATE) do |zip_file|
                files.each do |file|
                    file_path = File.join(path, file)
                    zip_file.add(file, file_path)
                end

            end

            # change back to previous directory
            Dir.chdir(cur_dir)
        end

        # helpers
        private
        #
        # Helper to sanitize the given chapter number so it is always 3 chars
        # long, with preceding zeros if the number is too short.
        #
        def _pad_num(num)
            num.to_s.rjust(3, '0')
        end
       
        #
        # Sanitizes name so that all space characters are _ and downcases the
        # entire string. Makes a string URL ready.
        #
        def _sanitize_name(name)
            name.to_s.downcase.gsub(/\s/, '_')
        end
    end
end
