module MangaGet
    module URL
        module_function
        def join(*parts)
            url = String.new
            parts.each do |p|
                p.gsub!(/\/$/, '')
                p.gsub!(/^\//, '')

                url << p
                url << '/' unless p == parts.last
                #url << '/' unless /\.html/ =~ p
            end
            url
        end
    end
end
