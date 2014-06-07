require 'spec_helper'

include MangaGet

RSpec.describe MangaSite::Page do
    describe "#new" do
        it "returns a new page" do
            expect(MangaSite::Page.new(nil, '', 0)).to be
        end
    end

    describe "#image" do
        context "when there is no image" do
            before do
                fake_url = 'https://duckduckgo.com'
                @page = MangaSite::Page.new(nil, fake_url, 0)
            end

            it "returns nil" do
                expect(@page.image).to be_nil
            end
        end

        context "when there is an image" do
            before do
                @series = create_series("Hunter X Hunter", site: MangaHere)
                chapter_url = URL.join(@series.url, 'v01/c001')
                @chapter = create_chapter(@series, url: chapter_url)
                page_url = URL.join(@chapter.url, '1.html')
                @page = MangaHere::Page.new(@chapter, page_url, 1)
            end

            it "returns an image object" do
                expect(@page.image).to be_instance_of Image
            end
        end
    end
end
