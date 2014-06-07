$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib/mget', __FILE__)

require 'rspec'
require 'matchers'

# load manga sites
require 'sites/manga_fox'
require 'sites/manga_here'
require 'sites/manga_panda'
require 'sites/manga_reader'

# helper methods to create fixtures
def create_site(options=Hash.new)
    if options.has_key? :site
        options[:site].new
    else
        MangaSite.new
    end
end

def create_series(name, options=Hash.new)
    if options.has_key? :site
        site = create_site(site: options[:site])
        options[:site]::Series.new(name, site)
    else
        MangaSite::Series.new(name, create_site)
    end
end

def create_chapter(series, options=Hash.new)
    url = options[:url] || URL.join(series.url, '/c001/')
    series.site.class::Chapter.new(series, url)
end

# rspec config
RSpec.configure do |config|
    config.include MangaGet
end
