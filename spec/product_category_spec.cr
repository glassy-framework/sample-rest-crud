require "./spec_helper.cr"

describe App::UserController do
  it "create product category" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    post_json "/product-categories", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {
          "name" => "My Category",
        },
      },
    }.to_json, headers

    response.status_code.should eq 201

    json_response = JSON.parse(response.body)

    json_response["data"]["attributes"]["name"].raw.should eq "My Category"
  end

  it "create product category (error auth)" do
    post_json "/product-categories", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {
          "name" => "My Category",
        },
      },
    }.to_json

    response.status_code.should eq 401
  end

  it "create product category (error name)" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    post_json "/product-categories", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {} of String => String,
      },
    }.to_json, headers

    response.status_code.should eq 400
  end

  it "show product category" do
    model = create_product_category do |model|
      model.name = "My Name"
    end

    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    get "/product-categories/#{model.id.to_s}", headers

    response.status_code.should eq 200

    json_response = JSON.parse(response.body)

    json_response["data"]["attributes"]["name"].raw.should eq "My Name"
  end

  it "show product category (error auth)" do
    model = create_product_category do |model|
      model.name = "My Name"
    end

    get "/product-categories/#{model.id.to_s}"

    response.status_code.should eq 401
  end

  it "show product eategory (error resource not found)" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    get "/product-categories/132123", headers

    response.status_code.should eq 404
  end

  it "update product category" do
    model = create_product_category do |model|
      model.name = "My Name 1"
      model.order = 5
    end

    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    patch_json "/product-categories/#{model.id.to_s}", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {
          "order" => 6,
        },
      },
    }.to_json, headers

    response.status_code.should eq 200

    json_response = JSON.parse(response.body)

    json_response["data"]["attributes"]["name"].raw.should eq "My Name 1"
    json_response["data"]["attributes"]["order"].raw.should eq 6
  end

  it "update product category (error not found)" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    patch_json "/product-categories/12431234", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {
          "order" => 6,
        },
      },
    }.to_json, headers

    response.status_code.should eq 404
  end

  it "update product category (error validation)" do
    model = create_product_category do |model|
      model.name = "My Name 1"
      model.order = 5
    end

    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    patch_json "/product-categories/#{model.id.to_s}", {
      "data" => {
        "type"       => "product-categories",
        "attributes" => {
          "name" => nil,
        },
      },
    }.to_json, headers

    response.status_code.should eq 400
  end

  it "remove product category" do
    model = create_product_category

    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    find_model = SpecContainer.kernel.container.product_category_repository.find_by_id(model.id.not_nil!)
    find_model.should_not be_nil

    delete "/product-categories/#{model.id.to_s}", headers

    response.status_code.should eq 204

    find_model = SpecContainer.kernel.container.product_category_repository.find_by_id(model.id.not_nil!)
    find_model.should be_nil
  end

  it "remove product category (no auth)" do
    model = create_product_category

    delete "/product-categories/#{model.id.to_s}"

    response.status_code.should eq 401
  end

  it "remove product category (not found)" do
    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    delete "/product-categories/10013123", headers

    response.status_code.should eq 404
  end

  it "list product category" do
    model1 = create_product_category
    model2 = create_product_category

    access_token = create_access_token(create_user)

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    get "/product-categories", headers

    response.status_code.should eq 200
    json_response = JSON.parse(response.body)
    json_response["data"].raw.as(Array).size.should eq 2
  end
end
