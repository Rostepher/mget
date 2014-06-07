module MangaGet
    class Image
        attr_reader :url, :file_format

        def initialize(url)
            @url = url
            @file_format = match_ext(@url)
        end

        private

        def match_ext(url)
            return nil if url.nil?

            match = /\.(?<file_format>jpg|jpeg|png)/.match(url)

            if match.nil?
                nil
            else
                match[:file_format] || nil
            end
        end
    end
end
