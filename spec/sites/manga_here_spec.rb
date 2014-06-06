require 'spec_helper'

include MangaGet

RSpec.describe MangaHere do
    describe "#new" do
        it "creates a new site" do
            expect(MangaHere.new).to be
        end
    end

    describe "#series" do
        it "returns a series" do
            MangaHere.new.series("Feng Shen Ji")
        end
    end
end

RSpec.describe MangaHere::Series do
    let(:series) { create_series("Feng Shen Ji", site: MangaHere) }
    let(:l_series) { create_series("Naruto", site: MangaHere) }
    let(:u_series) { create_series("One Piece", site: MangaHere) }

    describe "#new" do
        it "creates a new series" do
            expect(series).to be
        end
    end

    describe "#sanitized_name" do
        it "correctly sanitizes the series name" do
            expect(series.sanitized_name).to eq "feng_shen_ji"
        end
    end

    describe "#available?" do
        context "when a series is unavailable" do
            it "returns false" do
                expect(u_series.available?).to be false
            end
        end

        context "when a series is available" do
            it "returns true" do
                expect(series.available?).to be true
            end
        end
    end

    describe "#licensed?" do
        context "when a series is  licensed" do
            it "returns true" do
                expect(l_series.licensed?).to be true
            end
        end

        context "when a series is not licensed" do
            it "returns false" do
                expect(series.licensed?).to be false
            end
        end
    end

    describe "#url" do
        it "constructs the correct url" do
            expect(series.url).to match /http:\/\/www\.mangahere\.co\/manga\/feng_shen_ji\/{0,1}/
        end
    end

    describe "#chapters" do
        context "when a series is unavailable or licensed" do
            it "will be empty" do
                expect(u_series.chapters).to be_empty
            end
        end

        context "when a series is available" do
            it "will not be empty" do
                expect(series.chapters).to_not be_empty
            end

            it "will have unique chapters" do
                expect(series.chapters).to be_unique
            end
        end
    end
end

RSpec.describe MangaHere::Chapter do
    let(:series) { create_series("Feng Shen Ji", site: MangaHere) }

    describe "#new" do
        it "creates a new chapter" do
            url = series.chapters.first.url
            expect(MangaHere::Chapter.new(series, url)).to be
        end
    end

    before :each do
        @chapter = series.chapters.first
    end

    describe "#available?" do
        context "when the chapter is not available" do
            it "returns false" do
                chapter = create_chapter(series, url: "http://www.duckduckgo.com")
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
                expect(@chapter.volume).to be_nil
            end
        end

        context "when there is a volume" do
            it "returns the correct volume" do
                chapter = create_series("Hunter X Hunter", site: MangaHere).chapters.first
                expect(chapter.volume).to match /0*1/
            end
        end
    end

    describe "#chapter" do
        it "returns the correct chapter identifier" do
            expect(@chapter.chapter).to match /0*1/
        end
    end

    describe "#title" do
        context "when there is no title" do
            it "returns nil"
        end

        context "when there is a title" do
            it "returns the correct title"
        end
    end

    describe "#page_count" do
        it "returns the correct page count" do
            expect(@chapter.page_count).to eq(49) # Feng Shen Ji c001 has 49 pages
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

RSpec.describe MangaHere::Page do
end
