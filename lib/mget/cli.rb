require 'optparse'
require_relative 'version'

module MangaGet
    module CLI
        SOURCES = [:manga_fox, :manga_here, :manga_panda, :manga_stream]
        SOURCE_PATTERN = /^[manga][-|_](fox|here|panda|stream)$/i

        # parse command line args and return a hash
        module_function
        def parse_args
            
            # default options
            options = {
                :verbose   => false,
                :get_all   => false,
                :zip       => false,
                :source    => :manga_here,
                :chapters  => [],
                :directory => Dir.pwd,
                :threads   => 4
            }

            OptionParser.new do |opts|
                opts.banner = "Usage: mget [options] <manga name>"

                opts.on("-v", "--verbose", "Run this script verbosely") do |is_verbose|
                    options[:verbose] = is_verbose
                end

                opts.on("--all", "Gets all of the given manga") do |get_all|
                    options[:get_all] = get_all
                end

                opts.on("-z", "--zip", "Packages each chapter in a .cbz archive") do |zip|
                    options[:zip] = zip
                end

                opts.on("-s", "--source SOURCE", SOURCES,
                        "Source to pull manga from (default is mangahere)",
                        "   Sources: #{SOURCES}") do |source|
                    options[:source] = source unless source.nil?
                end

                opts.on("-c", "--chapters CHAPTERS", Array,
                        "Chapters to get separated by commas",
                        "   1,2-6,7..9,10...20 donwload chapters 1-20") do |array|
                    
                    chapters = Array.new
                    array.each do |elem|
                        match = /(\d+)(-|\.{2,3})(\d+)/.match(elem)

                        if match.nil?
                            chapters.push(elem.to_i)
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

                opts.on("-t", "--threads [THREADS]", Integer,
                        "Number of manga-get threads, max 12 (default 4)") do |threads|
                    options[:threads] = threads unless threads > 12
                end

                opts.on("-d", "--directory [DIR]",
                        "Directory to store saved chapters") do |dir|
                    options[:directory] = dir unless dir.nil?
                end

                opts.on_tail("--version", "Show version") do
                    puts MangaGet::VERSION
                    exit
                end

                opts.on_tail("-h", "--help", "Show this message") do
                    puts opts
                    exit
                end
            end.parse!

            return options
        end
    end
end
