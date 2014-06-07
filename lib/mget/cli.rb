require 'optparse'

require_relative 'string'
require_relative 'version'

module MangaGet
    module CLI
        SOURCES = [:manga_fox, :manga_here, :manga_panda, :manga_reader]

        #
        # Parse command line args and return a hash
        #
        module_function
        def parse_args
            options = {}
            parser = OptionParser.new

            # add options to parser
            parser.banner = "Usage: mget [options] <manga name>"

            parser.on("-v", "--verbose", "Run this script verbosely") do |bool|
                options[:verbose] = bool
            end

            parser.on("--all", "Gets all of the given manga") do |bool|
                options[:get_all] = bool
            end

            parser.on("-z", "--zip", "Packages each chapter in a .cbz archive") do |bool|
                options[:zip] = bool
            end

            parser.on("-s", "--source SOURCE", SOURCES,
                    "Source to pull manga from (default is mangahere)",
                    "   Sources: #{SOURCES}") do |source|
                options[:source] = source unless source.nil?
            end

            parser.on("-c", "--chapters CHAPTERS", Array,
                    "Chapters to get separated by commas",
                    "   1,2-6,7..9,10...20 donwload chapters 1-20") do |list|

                chapters = Array.new
                list.each do |elem|
                    match = /(\d+)(-|\.{2,3})(\d+)/.match(elem)

                    if match.nil?
                        chapters.push(elem.to_n)
                    else
                        lower = match[1].to_i
                        upper = match[3].to_i

                        chapters += if lower <= upper
                            (lower..upper).to_a
                        else
                            (upper..lower).to_a
                        end
                    end
                end

                # remove duplicates and sort
                options[:chapters] = chapters.uniq.sort!
            end

            parser.on("-t", "--threads THREADS", Integer,
                    "Number of manga-get threads, max 16 (default 4)") do |threads|
                options[:threads] = threads unless threads > 16 || threads <= 0
            end

            parser.on("-d", "--directory DIR",
                    "Directory to store saved chapters") do |dir|
                options[:dir] = dir unless dir.nil?
            end

            parser.on("-k", "--keep-temp", "Keep temp directories") do |bool|
                options[:keep_temp] = bool
            end

            parser.on_tail("--version", "Show version") do
                puts MangaGet::VERSION
                exit
            end

            parser.on_tail("-h", "--help", "Show this message") do
                puts parser.help
                exit
            end

            # parse args
            parser.parse!

            # if no manga specified print help and exit
            if ARGV.empty?
                puts parser.to_s
                exit
            end

            # everything left in ARGV is the manga name
            options[:manga] = ARGV.join(' ')

            # return options hash
            options
        end
    end
end
