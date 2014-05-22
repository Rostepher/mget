require 'nokogiri'
require 'open-uri'

IMG_PATTERN = /src=\"(.*)\" o/

def get_img(url, name)
    File.open(name, 'wb') do |fo|
        fo.write(open(url).read)
    end
end

url = "http://www.mangahere.co/manga/feng_shen_ji/c107"
page = Nokogiri::HTML(open(url)).at('body')
match = IMG_PATTERN.match(page.css('.read_img img').to_s)
puts match[1]

temp_dir = File.join(Dir.pwd, "temp")
Dir.rmdir(temp_dir)

# create temp directory
Dir.mkdir(temp_dir, 0755)
Dir.chdir(temp_dir)

get_img(match[1], "001.jpg")
