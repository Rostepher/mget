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

        # delimeter for names
        NAME_DELIM = '_'

        # regex defining what image types are used
        IMAGE_TYPE_REGEX = /(jpg|jpeg|png)/
        # regex used to find image files to zip 
        FILE_NAME_REGEX = /\d{3}\.(jpg|jpeg|png)/i

        attr_reader :manga, :chapters, :options

        def initialize(manga, pool_size=4, options=Hash.new)
            @manga = Helpers::sanitize_str(manga, self.class::NAME_DELIM)
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

        # Scrapes source and downloads all images in a chapter then zips all
        # the images into a cbz archive.
        #
        # @param chapter [Integer, Float] the chapter number
        def get_chapter(chapter)
            # check if the chapter is available
            if !chapter_available?(chapter)
                raise ChapterNotAvailableError.new(@manga, chapter, @options[:source])
            end

            verbose "Getting \"#{Helpers::fmt_title(@manga)}\":#{Helpers::pad(chapter)}"
            
            # make directory to hold chapter
            path = chapter_path(chapter)
            FileUtils.mkdir_p(path)

            # traverse each image and download
            images = get_image_urls(chapter)
            images.each.with_index do |url, i|
                name = Helpers::pad(i + 1)
                download_image(url, path, name)
            end

            # zip if the zip option is set
            zip_chapter(chapter) if @options[:zip]
        end

        # Downloads all chapters in a given list, must only contain Integers.
        # Each chapter is assigned as a task to a thread in the pool, thus
        # allowing multiple chapters to be downloaded at once.
        #
        # @params list [Array<Integer, Float>] an array of chapter numbers
        def get_chapters(list)
            # check if manga is licensed then available
            if licensed?
                raise MangaLicensedError.new(@manga, @options[:source]) 
            elsif !manga_available?
                raise MangaNotAvailableError.new(@manga, @options[:source])
            end

            # create temp path
            verbose "Creating temp dir #{@temp_dir}"
            FileUtils.mkdir_p(@temp_dir)

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
            path = chapter_path(chapter)
            zip_name = "#{@manga}.c#{Helpers::pad(chapter)}.cbz"

            verbose "Creating #{zip_name}"

            zip_dir(path, zip_name, FILE_NAME_REGEX) if Dir.exists?(path)
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
        
        # not implemented
        def manga_url
            raise NotImplementedError
        end

        def chapter_path(chapter)
            raise NotImplementedError
        end

        def manga_available?
            raise NotImplementedError
        end

        def chapter_available?
            raise NotImplementedError
        end

        def licensced?
            raise NotImplementedError
        end

        def get_chapters_hash
            raise NotImplementedError
        end

        def get_chapter_urls
            raise NotImplementedError
        end

        def get_page_urls(chapter)
            raise NotImplementedError
        end

        def get_image_urls(chapter)
            raise NotImplementedError
        end
    end
end
