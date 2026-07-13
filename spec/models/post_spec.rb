require "rails_helper"

RSpec.describe Post, type: :model do
  subject(:post) { described_class.new(attributes) }

  let(:attributes) do
    {
      title: "Hotwire Search",
      description: "Instant results as you type",
      body: "Built with Turbo and Stimulus"
    }
  end

  describe "validations" do
    it "is valid with title, description, and body" do
      expect(post).to be_valid
    end

    it "requires a title" do
      post.title = nil
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it "requires a description" do
      post.description = " "
      expect(post).not_to be_valid
      expect(post.errors[:description]).to include("can't be blank")
    end

    it "allows a blank body" do
      post.body = nil
      expect(post).to be_valid
    end
  end

  describe ".ransackable_attributes" do
    it "exposes title, description, and body for search" do
      expect(described_class.ransackable_attributes).to match_array(%w[title description body])
    end
  end

  describe ".ransackable_associations" do
    it "does not expose associations for search" do
      expect(described_class.ransackable_associations).to eq([])
    end
  end

  describe "search with ransack" do
    let!(:matching_title) do
      described_class.create!(
        title: "Turbo Frames Guide",
        description: "How frames work",
        body: "Unrelated content"
      )
    end
    let!(:matching_description) do
      described_class.create!(
        title: "Something else",
        description: "Deep dive into turbo streams",
        body: "Still unrelated"
      )
    end
    let!(:matching_body) do
      described_class.create!(
        title: "Another post",
        description: "Plain description",
        body: "Learn turbo morphing here"
      )
    end
    let!(:unrelated) do
      described_class.create!(
        title: "PostgreSQL tips",
        description: "Indexes and vacuum",
        body: "Database maintenance notes"
      )
    end

    def search(query)
      described_class.ransack(title_or_description_or_body_cont: query).result(distinct: true)
    end

    it "finds posts by title" do
      expect(search("Frames")).to contain_exactly(matching_title)
    end

    it "finds posts by description" do
      expect(search("streams")).to contain_exactly(matching_description)
    end

    it "finds posts by body" do
      expect(search("morphing")).to contain_exactly(matching_body)
    end

    it "finds posts across title, description, and body" do
      expect(search("turbo")).to contain_exactly(
        matching_title,
        matching_description,
        matching_body
      )
    end

    it "is case-insensitive" do
      expect(search("TURBO")).to contain_exactly(
        matching_title,
        matching_description,
        matching_body
      )
    end

    it "returns no posts when nothing matches" do
      expect(search("zzzz-no-match")).to be_empty
    end
  end
end
