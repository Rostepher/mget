module MangaGet
    class Image
        attr_reader :url, :file_format

        def initialize(url)
            @url = url
            @file_format = file_format
        end

        private

        def ext
            /\.(?<file_formt>jpg|jpeg|png)/.match(@url)[:file_format]
        end
    end
end
