require 'fileutils'
require 'zip'

module MangaGet
    module Util
        IMAGE_EXT_REGEX = /\.(jpg|jpeg|png)/i

        # Downloads an image from the given url to the given path with the
        # given name.
        #
        # @param url [String] url for image
        # @param path [String] path to save the image to
        # @param name [String] name to give the saved image file
        module_function
        def download_image(url, path, name)
            IMAGE_EXT_REGEX =~ url
            ext = $1

            image = "#{File.join(path, name)}.#{ext}"
            open(image, 'wb') do |file|
                file << open(url).read
            end
        end

        # Helper method to zip all files in a directory that match the given
        # file_regex.
        #
        # @param dir [String] directory to glob files from
        # @param zip_name [String] name to give the created zip archive
        # @param file_regex [Regexp] regex used to glob files
        module_function
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
    end
end
