require "rails_helper"

RSpec.describe "/posts", type: :request do
  let(:valid_attributes) do
    {
      title: "Hello world",
      description: "This is description for Hello world",
      body: "This is body for Hello world"
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      description: "",
      body: "This is body"
    }
  end

  describe "GET /index" do
    it "renders a successful response with search UI" do
      Post.create!(valid_attributes)

      get posts_url

      expect(response).to be_successful
      expect(response.body).to include("Hotwire")
      expect(response.body).to include("Search")
      expect(response.body).to include('id="results"')
      expect(response.body).to include('name="q[title_or_description_or_body_cont]"')
    end

    it "renders an empty posts container for infinite scroll" do
      get posts_url

      expect(response.body).to include('id="posts"')
      expect(response.body).to include('id="pagination"')
    end
  end

  describe "GET /index.turbo_stream" do
    before do
      Post.create!(title: "First", description: "Desc one", body: "Body one")
      Post.create!(title: "Second", description: "Desc two", body: "Body two")
      Post.create!(title: "Third", description: "Desc three", body: "Body three")
    end

    it "appends the first page of posts" do
      get posts_url(format: :turbo_stream)

      expect(response).to be_successful
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include('action="append" target="posts"')
      expect(response.body).to include("First")
      expect(response.body).to include("Second")
      expect(response.body).not_to include("Third")
    end

    it "loads the next page when page is provided" do
      get posts_url(format: :turbo_stream, page: 2)

      expect(response).to be_successful
      expect(response.body).to include("Third")
      expect(response.body).not_to include(">First<")
    end

    it "includes a clickable post result card" do
      get posts_url(format: :turbo_stream)

      expect(response.body).to include('class="post-result"')
      expect(response.body).to include("data-turbo-frame=\"_top\"")
    end

    it "replaces pagination when more pages remain" do
      get posts_url(format: :turbo_stream)

      expect(response.body).to include('action="replace" target="pagination"')
      expect(response.body).to include("page=2")
    end
  end

  describe "search" do
    let!(:rails_post) do
      Post.create!(
        title: "Rails 8 guide",
        description: "Framework updates",
        body: "Load defaults and solid adapters"
      )
    end
    let!(:hotwire_post) do
      Post.create!(
        title: "Frontend tips",
        description: "Hotwire patterns",
        body: "Use turbo frames carefully"
      )
    end
    let!(:other_post) do
      Post.create!(
        title: "Cooking pasta",
        description: "Boil water first",
        body: "Salt the water generously"
      )
    end

    it "returns matching posts in turbo stream results" do
      get posts_url(
        format: :turbo_stream,
        q: { title_or_description_or_body_cont: "Hotwire" }
      )

      expect(response).to be_successful
      expect(response.body).to include(hotwire_post.title)
      expect(response.body).not_to include(rails_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "matches against title, description, and body" do
      get posts_url(
        format: :turbo_stream,
        q: { title_or_description_or_body_cont: "Rails" }
      )

      expect(response.body).to include(%(<mark>Rails</mark> 8 guide))
      expect(response.body).not_to include(hotwire_post.title)
    end

    it "highlights the matched query in results" do
      get posts_url(
        format: :turbo_stream,
        q: { title_or_description_or_body_cont: "Hotwire" }
      )

      expect(response.body).to include("<mark>Hotwire</mark>")
    end

    it "returns no post cards when the query matches nothing" do
      get posts_url(
        format: :turbo_stream,
        q: { title_or_description_or_body_cont: "zzzz-no-match" }
      )

      expect(response).to be_successful
      expect(response.body).not_to include("class=\"post-result\"")
    end

    it "keeps the search query on the index page form" do
      get posts_url(q: { title_or_description_or_body_cont: "Hotwire" })

      expect(response).to be_successful
      expect(response.body).to include('value="Hotwire"')
    end

    it "paginates filtered search results" do
      3.times do |i|
        Post.create!(
          title: "Hotwire tip #{i}",
          description: "Pattern #{i}",
          body: "Details #{i}"
        )
      end

      get posts_url(
        format: :turbo_stream,
        q: { title_or_description_or_body_cont: "Hotwire tip" }
      )

      expect(response.body).to include(%(<mark>Hotwire tip</mark> 0))
      expect(response.body).to include(%(<mark>Hotwire tip</mark> 1))
      expect(response.body).not_to include(%(<mark>Hotwire tip</mark> 2))
      expect(response.body).to include("page=2")
    end
  end

  describe "GET /show" do
    it "renders the post details" do
      post = Post.create!(valid_attributes)

      get post_url(post)

      expect(response).to be_successful
      expect(response.body).to include(post.title)
      expect(response.body).to include(post.description)
      expect(response.body).to include(post.body)
      expect(response.body).to include("Edit")
      expect(response.body).to include("Back to search")
      expect(response.body).to include("Delete")
    end

    it "returns not found for a missing post" do
      get post_url(id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "renders the new post form" do
      get new_post_url

      expect(response).to be_successful
      expect(response.body).to include("New post")
      expect(response.body).to include('action="/posts"')
      expect(response.body).to include("Back to search")
    end
  end

  describe "GET /edit" do
    it "renders the edit post form" do
      post = Post.create!(valid_attributes)

      get edit_post_url(post)

      expect(response).to be_successful
      expect(response.body).to include("Edit post")
      expect(response.body).to include(post.title)
      expect(response.body).to include("View post")
      expect(response.body).to include("Back to search")
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Post" do
        expect {
          post posts_url, params: { post: valid_attributes }
        }.to change(Post, :count).by(1)
      end

      it "redirects to the created post with a notice" do
        post posts_url, params: { post: valid_attributes }

        expect(response).to redirect_to(post_url(Post.last))
        follow_redirect!
        expect(response.body).to include("Post was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Post" do
        expect {
          post posts_url, params: { post: invalid_attributes }
        }.not_to change(Post, :count)
      end

      it "re-renders the new template with errors" do
        post posts_url, params: { post: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("error")
        expect(response.body).to include("New post")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          title: "Goodbye world",
          description: "Updated description",
          body: "Updated body"
        }
      end

      it "updates the requested post" do
        post = Post.create!(valid_attributes)

        patch post_url(post), params: { post: new_attributes }
        post.reload

        expect(post.title).to eq("Goodbye world")
        expect(post.description).to eq("Updated description")
        expect(post.body).to eq("Updated body")
      end

      it "redirects to the post with a notice" do
        post = Post.create!(valid_attributes)

        patch post_url(post), params: { post: new_attributes }

        expect(response).to redirect_to(post_url(post))
        follow_redirect!
        expect(response.body).to include("Post was successfully updated.")
        expect(response.body).to include("Goodbye world")
      end
    end

    context "with invalid parameters" do
      it "re-renders the edit template with errors" do
        post = Post.create!(valid_attributes)

        patch post_url(post), params: { post: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("error")
        expect(response.body).to include("Edit post")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested post" do
      post = Post.create!(valid_attributes)

      expect {
        delete post_url(post)
      }.to change(Post, :count).by(-1)
    end

    it "redirects to the posts list with a notice" do
      post = Post.create!(valid_attributes)

      delete post_url(post)

      expect(response).to redirect_to(posts_url)
      expect(flash[:notice]).to eq("Post was successfully destroyed.")
    end
  end
end
