require "./spec_helper.cr"

describe App::Product do
  it "create product" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    io = IO::Memory.new
    content_type = nil

    HTTP::FormData.build(io) do |formdata|
      content_type = formdata.content_type

      formdata.field("json", {
        "data" => {
          "type"       => "products",
          "attributes" => {
            "name" => "Plant One",
          },
        },
      }.to_json)

      File.open(__DIR__ + "/fixtures/images/plant.jpeg") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "myplant.jpeg")
        headers = HTTP::Headers{"Content-Type" => "image/jpeg"}
        formdata.file("image", file, metadata, headers)
      end
    end

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"
    headers["Content-Type"] = content_type.not_nil!
    body = io.to_s

    post "/product-categories/#{category_id}/products", headers, body

    response.status_code.should eq 201

    json_response = JSON.parse(response.body)
    json_response["data"]["attributes"]["name"].raw.should eq "Plant One"

    product_repository = SpecContainer.kernel.container.app_product_repository
    product = product_repository.find_by_id(json_response["data"]["id"].raw.as(String))

    product.should_not be_nil
    product = product.not_nil!
    product.name.should eq "Plant One"
    product.category_id.should eq category.id
    product.image.should_not be_nil
    product.order.should eq 1

    # second product
    post "/product-categories/#{category_id}/products", headers, body

    response.status_code.should eq 201

    json_response = JSON.parse(response.body)
    json_response["data"]["attributes"]["name"].raw.should eq "Plant One"
    json_response["data"]["attributes"]["order"].raw.should eq 2

    delete "/product-categories/#{category_id}/products/#{json_response["data"]["id"]}", headers
  end

  it "create product (validation error)" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"
    headers["Content-Type"] = "application/json"

    post "/product-categories/#{category_id}/products", headers, {
      "data" => {
        "type"       => "products",
        "attributes" => {
          "name" => "Plant One",
        },
      },
    }.to_json

    response.status_code.should eq 400
  end

  it "update only name" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    product = create_product do |product|
      product.name = "Original Name"
      product.image = "original.jpeg"
      product.category_id = category.id
    end

    product_id = product.id.to_s

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"
    headers["Content-Type"] = "application/json"

    patch "/product-categories/#{category_id}/products/#{product_id}", headers, {
      "data" => {
        "attributes" => {
          "name" => "My name",
        },
      },
    }.to_json

    response.status_code.should eq 200
    json_response = JSON.parse(response.body)
    json_response["data"]["attributes"]["name"].raw.should eq "My name"
  end

  it "update image" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    product = create_product do |product|
      product.name = "Original Name"
      product.image = "original.jpeg"
      product.category_id = category.id
    end

    product_id = product.id.to_s

    io = IO::Memory.new
    content_type = nil

    HTTP::FormData.build(io) do |formdata|
      content_type = formdata.content_type

      formdata.field("json", {
        "data" => {
          "type"       => "products",
          "attributes" => {} of String => String,
        },
      }.to_json)

      File.open(__DIR__ + "/fixtures/images/plant.jpeg") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "myplant.jpeg")
        headers = HTTP::Headers{"Content-Type" => "image/jpeg"}
        formdata.file("image", file, metadata, headers)
      end
    end

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"
    headers["Content-Type"] = content_type.not_nil!

    body = io.to_s

    patch "/product-categories/#{category_id}/products/#{product_id}", headers, body

    response.status_code.should eq 200
    json_response = JSON.parse(response.body)
    json_response["data"]["attributes"]["name"].raw.should eq "Original Name"
    json_response["data"]["attributes"]["image"].raw.should_not be_nil
    json_response["data"]["attributes"]["image"].raw.should_not eq ""
    json_response["data"]["attributes"]["image"].raw.should_not eq product.image
  end

  it "update (validation error)" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    product = create_product do |product|
      product.name = "Original Name"
      product.image = "original.jpeg"
      product.category_id = category.id
    end

    product_id = product.id.to_s

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"
    headers["Content-Type"] = "application/json"

    patch "/product-categories/#{category_id}/products/#{product_id}", headers, {
      "data" => {
        "attributes" => {
          "name" => nil,
        },
      },
    }.to_json

    response.status_code.should eq 400
  end

  it "delete" do
    access_token = create_access_token(create_user)
    category = create_product_category()
    category_id = category.id.to_s

    product = create_product do |product|
      product.name = "Original Name"
      product.image = "original.jpeg"
      product.category_id = category.id
    end

    product_id = product.id.to_s

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    delete "/product-categories/#{category_id}/products/#{product_id}", headers

    response.status_code.should eq 204
  end

  it "get product" do
    access_token = create_access_token(create_user)
    category_one = create_product_category()
    category_one_id = category_one.id.to_s
    category_two = create_product_category()

    product_one = create_product do |product|
      product.name = "Product One"
      product.category_id = category_one.id
    end
    product_one_id = product_one.id.to_s

    product_two = create_product do |product|
      product.name = "Product two"
      product.category_id = category_two.id
    end
    product_two_id = product_two.id.to_s

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    get "/product-categories/#{category_one_id}/products/#{product_one_id}", headers

    response.status_code.should eq 200

    json_response = JSON.parse(response.body)
    json_response["data"]["attributes"]["name"].raw.should eq "Product One"

    get "/product-categories/#{category_one_id}/products/#{product_two_id}", headers

    response.status_code.should eq 404
  end

  it "list product" do
    access_token = create_access_token(create_user)
    category_one = create_product_category()
    category_one_id = category_one.id.to_s
    category_two = create_product_category()

    create_product do |product|
      product.name = "Product One"
      product.category_id = category_one.id
    end

    create_product do |product|
      product.name = "Product two"
      product.category_id = category_two.id
    end

    headers = HTTP::Headers.new
    headers["Authorization"] = "Bearer #{access_token}"

    get "/product-categories/#{category_one_id}/products", headers

    response.status_code.should eq 200

    json_response = JSON.parse(response.body)
    json_response["data"].raw.as(Array).size.should eq 1
    json_response["data"][0]["attributes"]["name"].should eq "Product One"
  end
end
