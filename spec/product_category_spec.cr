require "./spec_helper.cr"

describe App::UserController do
  it "create product category" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    post_json "/product-categories", {
      "data" => {
        "type" => "product-categories",
        "attributes" => {
          "name" => "My Category"
        }
      }
    }.to_json, headers

    response.status_code.should eq 201
  end
end
