require_relative 'cli'
require_relative 'scrapers/manga_here'
require_relative 'scrapers/manga_panda'
require_relative 'scrapers/manga_fox'
require_relative 'scrapers/manga_reader'

include MangaGet

# parse options
options = CLI::parse_args
threads = options[:threads] || 4
manga = options[:manga]

# create new scraper, manga_here is default
s = case options[:source]
    when :manga_fox
        MangaFoxScraper.new(manga, threads, options)
    when :manga_panda
        MangaPandaScraper.new(manga, threads, options)
    when :manga_reader
        MangaReaderScraper.new(manga, threads, options)
    else
        MangaHereScraper.new(manga, threads, options)
    end

# get the chapters
begin
    s.get_chapters(options[:chapters])
rescue Errors::MangaLicensedError => e
    $stderr.puts e.message
    exit
rescue Errors::MangaNotAvailableError => e
    $stderr.puts e.message
    exit
end
