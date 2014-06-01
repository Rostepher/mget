require 'zip'
require 'fileutils'

require_relative '../errors'
require_relative '../helpers'
require_relative '../string'
require_relative '../thread_pool'

module MangaGet
    class Scraper
        include MangaGet
        include MangaGet::Errors

        # regex defining what image types are used
        IMAGE_TYPE_REGEX = /(jpg|jpeg|png)/
       
        attr_reader :manga

        def initialize(manga, pool_size=4, options=Hash.new)
            @manga = Helpers::sanitize_str(manga)
            @thread_pool = ThreadPool.new(pool_size)
            @temp_dir = File.join(Dir.getwd, @manga)

            # scrape and save list of all chapter urls
            @chapters = get_chapters_hash

            # parse options
            @options = {
                :verbose   => options[:verbose]   || false,
                :get_all   => options[:get_all]   || false,
                :zip       => options[:zip]       || false,
                :source    => options[:source]    || :manga_here,
                :keep_temp => options[:keep_temp] || false
            }
        end

        def manga_available?
            # reimplement in child classes
            raise NotImplementedError
        end

        def chapter_available?
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapters_hash
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapter_urls
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_page_urls(chapter)
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_image_urls(chapter)
            # reimplement in child classes
            raise NotImplementedError
        end

        def get_chapter(chapter)
            # reimplement in child classes
            raise NotImplementedError
        end

        # Downloads all chapters in a given list, must only contain Integers.
        # Each chapter is assigned as a task to a thread in the pool, thus
        # allowing multiple chapters to be downloaded at once.
        #
        # @params list [Array<Integer, Float>] an array of chapter numbers
        def get_chapters(list)
            unless manga_available?
                raise MangaNotAvailableError.new(@manga, @options[:source])
            end

            # create temp path
            verbose "Creating temp dir #{@temp_dir}"
            FileUtils.mkdir(@temp_dir)

            # option to get all is set
            list = @chapters.keys if @options[:get_all]

            list.each do |chapter| 
                @thread_pool.schedule do
                    begin
                        get_chapter(chapter)
                    rescue ChapterNotAvailableError => e
                        $stderr.puts e.message
                    end
                end
            end

            # wait for threads to finish
            @thread_pool.join

            # remove temp dir if keep_temp option is false
            unless @options[:keep_temp]
                verbose "Removing temp directory #{@temp_dir}"
                FileUtils.rm_r(@temp_dir)
            end            
        end

        private

        # Downloads an image from the given url to the given path with the
        # given name.
        #
        # @param url [String] url for image
        # @param path [String] path to save the image to
        # @param name [String] name to give the saved image file
        def download_image(url, path, name)
            match = IMAGE_TYPE_REGEX.match(url)

            image = "#{File.join(path, name)}.#{match[0]}"
            open(image, 'wb') do |file|
                file << open(url).read 
            end
        end

        # Zips a directory of images into a cbz archive with the the name.
        # This method assumes the existence of the chapter and directory
        # structure @manga/c### in the current working directory.
        #
        # @param chapter [Integer, Float] the chapter number
        def zip_chapter(chapter)
            chapter = Helpers::pad(chapter)

            path = File.join(@temp_dir, "c#{chapter}")
            zip_name = "#{@manga}.c#{chapter}.cbz"
            file_regex = /\d{3}\.(jpg|jpeg|png)/i

            verbose "Creating #{zip_name}"

            zip_dir(path, zip_name, file_regex) if Dir.exists?(path)
        end
       
        # Helper method to zip all files in a directory that match the given
        # file_regex.
        #
        # @param dir [String] directory to glob files from
        # @param zip_name [String] name to give the created zip archive
        # @param file_regex [Regexp] regex used to glob files
        def zip_dir(dir, zip_name, file_regex)
            # change directory to target
            cur_dir = Dir.getwd
            Dir.chdir(dir)

            # glob and sort files to zip
            files = Dir.glob('*').select { |f| f =~ file_regex }.sort!

            # change back to previous directory
            Dir.chdir(cur_dir)

            # zip files
            Zip::File.open(zip_name, Zip::File::CREATE) do |zip_file|
                files.each do |file|
                    file_path = File.join(dir, file)
                    zip_file.add(file, file_path)
                end

            end
        end

        # Prints given message if in verbose mode.
        #
        # @param msg [String] message to print to STDOUT
        # @param tabs [Integer] number of tabs to indent message, default is 0
        def verbose(msg, tabs=0)
            _tab = "    " # four spaces
            puts (_tab * tabs) + msg if @options[:verbose]
        end
    end
end
