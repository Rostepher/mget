require 'spec_helper'
require 'image'

include MangaGet

RSpec.describe Image do
    describe "#new" do
        let(:image) { Image.new(nil) }

        it "returns an image instance" do
            expect(image).to be
            expect(image).to be_instance_of Image
        end
    end

    describe "#url" do
        let(:url) { 'http://duckduckgo.com' }
        let(:image) { Image.new(url) }

        it "returns the correct url" do
            expect(image.url).to eq(url)
        end
    end

    describe "#file_format" do
        let(:image) { Image.new('image.jpg') }

        it "returns the corrent file format" do
            expect(image.file_format).to eq("jpg")
        end
    end
end
