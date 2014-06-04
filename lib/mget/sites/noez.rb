require_relative 'manga_site'

module MangaGet
    class Noez < MangaSite
        class Series < MangaSite::Series

            # Returns a url safe, 'sanitized' copy of {Noez::Series#name
            # Series#name} that is formatted for Noez sites.
            #
            # @returns [String] sanitized, url safe name
            def sanitized_name
                @name.downcase.gsub(/[\s\.\-_]/, '_')
            end

            # Returns if the manga series is available on the noez mangasites.
            # This method uses a cached value if present or if forced is true
            # it will re-check. If the manga is licensed, then it returns
            # false.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [true, false] if the manga series is available
            def available?(refresh=false)
                # check for cached value
                if @cache.has_key? :available && !refresh
                    return @cache[:available]
                end

                # if the series is licensed it is not available
                if licensed?
                    return @cache[:available] = false
                end

                # open manga page and check if there are any chapters listed
                page = Nokogiri::HTML(open(url))
                @cache[:available] = \
                    !page.xpath(self.class::CHAPTERS_FROM_SOURCE_XPATH).nil?
            end

            # Returns if the manga series is licensed on the noez mangasites.
            # This method uses a cached value if present or if forced is true
            # it will re-check.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [true, false] if the manga series is licensed
            def licensed?(refresh=false)
                # check for cached value
                if @cache.has_key? :licensed && !refresh
                    return @cache[:licensed]
                end

                @cache[:licensed] = open(url, &:read).include?("licensed")
            end

            # Creates and returns a sorted array of {Chapter Chapter} objects
            # for each chapter in the {Series Series}.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [Array<Noez::Chapter>] sorted array of chapters
            def chapters(refresh=false)
                # check for cached value
                if @cache.has_key? :chapters && !refresh
                    return @cache[:chapters]
                end

                page = Nokogiri::HTML(open(url))

                chapters = Array.new
                page.xpath(self.class::CHAPTERS_FROM_SOURCE_XPATH).each do |m|
                    chapters << @site.class::Chapter.new(self, m[:href])
                end

                # sort by chapter number
                @cache[:chapters] = chapters.sort_by { |c| c.chapter }
            end
        end

        class Chapter < MangaSite::Chapter

            # Returns if the manga chapter is available on the noez mangasites.
            # If the manga is licensed, then it return false.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [true, false] if the manga series is available
            def available?(refresh=false)
                # check for cached value
                if @cache.has_key? :available && !refresh
                    return @cache[:available]
                end

                # if the series is licensed it is not available
                if @series.licensed?
                    return @cache[:available] = false
                end

                @series.chapters.each do |c|
                    return true if c.chapter == chapter
                end

                false
            end

            # Always returns nil, as aftv sites, like mangapand don't track
            # volume numbers in the urls.
            #
            # @returns [nil] nil
            def volume(refresh=false)
                nil
            end

            # Creates and returns a sorted array of {MangaSite::Page Page}
            # objects for each page in the {Noez::Chapter Chapter}.
            #
            # @returns [Array<MangaSite::Page>] sorted array of pages
            def pages
                pages = Array.new
                1.upto(page_count) do |number|
                    page_url = URL::join(@url, "/#{number}.html")
                    site_class = @series.site.class
                    pages << site_class::Page.new(self, page_url, number)
                end

                # sort by page number
                pages.sort_by { |p| p.number }
            end
        end
    end
end
