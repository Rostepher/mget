require_relative 'cli'

module MangaGet
    include CLI
    puts CLI::parse_args
end
