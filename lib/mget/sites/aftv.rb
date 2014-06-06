require_relative 'manga_site'

module MangaGet
    class Aftv < MangaSite
        class Series < MangaSite::Series
            def sanitized_name
                @name.downcase.gsub(/[\s\.\-_]/, '-')
            end

            def available?(refresh=false)
                if @cache.has_key? :available && !refresh
                    return @cache[:available]
                end

                p url
                page = Nokogiri::HTML(open(url))
                @cache[:available] = \
                    !page.xpath(self.class::CHAPTERS_FROM_SOURCE_XPATH).nil?
            end

            def licensed?(refresh=false)
                # aftv sites like mangapanda and mangareader don't care about
                # licensing.
                false
            end

            # Creates and returns a sorted array of {Aftv:LChapter Chapter}
            # objects for each chapter in the {Series Series}.
            #
            # @param refresh [true, false] force the value to be refreshed
            # @returns [Array<Aftv::Chapter>] sorted array of chapters
            def chapters(refresh=false)
                # check for cached value
                if @cache.has_key? :chapters && !refresh
                    return @cache[:chapters]
                end

                page = Nokogiri::HTML(open(url))

                chapters = Array.new
                page.xpath(self.class::CHAPTERS_FROM_SOURCE_XPATH).each do |m|
                    # aftv sites have links that are portions of the full url
                    # '/feng-shen-ji/108' vs the entire url
                    chapter_url = @site.class::BASE_URL + m[:href]
                    chapters << @site.class::Chapter.new(self, chapter_url)
                end

                # sort by chapter number
                @cache[:chapters] = chapters.sort_by { |c| c.chapter }
            end
        end

        class Chapter < MangaSite::Chapter
            def available?(refresh=false)
                if @cache.has_key? :available && !refresh
                    return @cache[:available]
                end

                @series.chapters.each do |c|
                    return true if c.chapter == chapter
                end

                false
            end

            def pages
                pages = Array.new
                1.upto(page_count) do |number|
                    # if the url ends with '.html'
                    page_url = if /\.html$/ =~ url
                        url.gsub(/(\d+)-(\d+)-(\d+)/, "#{$1}-#{$2}-#{number}")
                    else
                        url + "/#{number}"
                    end
                    site_class = @series.site.class
                    pages << site_class::Page.new(self, page_url, number)
                end

                pages.sort_by { |p| p.number }
            end
        end
    end
end
