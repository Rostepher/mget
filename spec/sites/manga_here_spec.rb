require 'spec_helper'

REGULAR_SERIES = "Hunter X Hunter"
LICENSED_SERIES = "One Piece"

include MangaGet

RSpec.describe MangaHere do
    describe "#new" do
        it "creates a new site" do
            expect(MangaHere.new).to be
        end
    end

    describe "#series" do
        it "returns a series" do
            MangaHere.new.series(REGULAR_SERIES)
        end
    end
end

RSpec.describe MangaHere::Series do
    let(:regular_series) { create_series(REGULAR_SERIES, site: MangaHere) }
    let(:licensed_series) { create_series(LICENSED_SERIES, site: MangaHere) }

    describe "#new" do
        it "creates a new series" do
            expect(regular_series).to be
        end
    end

    describe "#sanitized_name" do
        it "correctly sanitizes the series name" do
            sanitized_name = REGULAR_SERIES.downcase.gsub(/\s|-/, '_')
            expect(regular_series.sanitized_name).to eq sanitized_name
        end
    end

    describe "#available?" do
        context "when a series is unavailable" do
            it "returns false" do
                expect(licensed_series.available?).to be false
            end
        end

        context "when a series is available" do
            it "returns true" do
                expect(regular_series.available?).to be true
            end
        end
    end

    describe "#licensed?" do
        context "when a series is  licensed" do
            it "returns true" do
                expect(licensed_series.licensed?).to be true
            end
        end

        context "when a series is not licensed" do
            it "returns false" do
                expect(regular_series.licensed?).to be false
            end
        end
    end

    describe "#url" do
        it "constructs the correct url" do
            name = regular_series.sanitized_name
            url_regex = /http:\/\/(www\.|)mangahere\.co\/manga\/#{name}\/{0,1}/o
            expect(regular_series.url).to match url_regex
        end
    end

    describe "#chapters" do
        context "when a series is unavailable or licensed" do
            it "will be empty" do
                expect(licensed_series.chapters).to be_empty
            end
        end

        context "when a series is available" do
            it "will not be empty" do
                expect(regular_series.chapters).to_not be_empty
            end

            it "will have unique chapters" do
                expect(regular_series.chapters).to be_unique
            end
        end
    end
end

RSpec.describe MangaHere::Chapter do
    let(:regular_series) { create_series(REGULAR_SERIES, site: MangaHere) }
    let(:no_vol_series) { create_series("Feng Shen Ji", site: MangaHere) }

    describe "#new" do
        it "creates a new chapter" do
            expect(create_chapter(regular_series)).to be
        end
    end

    before :each do
        @chapter = regular_series.chapters.first
    end

    describe "#available?" do
        context "when the chapter is not available" do
            it "returns false" do
                fake_url = "http://www.duckduckgo.com"
                chapter = create_chapter(regular_series, url: fake_url)
                expect(chapter.available?).to be false
            end
        end

        context "when the chapter is available?" do
            it "returns true" do
                expect(@chapter.available?).to be true
            end
        end
    end

    describe "#volume" do
        context "when there is no volume" do
            it "returns nil" do
                chapter = no_vol_series.chapters.first
                expect(chapter.volume).to be_nil
            end
        end

        context "when there is a volume" do
            it "returns the correct volume" do
                expect(@chapter.volume).to match /0*1/
            end
        end
    end

    describe "#chapter" do
        it "returns the correct chapter identifier" do
            expect(@chapter.chapter).to match /0*1/
        end
    end

    describe "#page_count" do
        it "returns the correct page count" do
            # Hunter X Hunter chapter 1 has 33 pages
            expect(@chapter.page_count).to eq(33)
        end
    end

    describe "#pages" do
        # assume chapter exists
        it "is not empty" do
            expect(@chapter.pages).to_not be_empty
        end

        it "has all unique pages" do
            expect(@chapter.pages).to be_unique
        end
    end
end
