require "awscr-s3"
require "random"
require "mime"

module App
  class StorageService
    def initialize(@client : Awscr::S3::Client, @default_bucket : String, @public_url_pattern : String)
    end

    def generate_random_name(ext : String)
      Random::Secure.hex + ".#{ext}"
    end

    def upload_file(file : File, target_name : String, bucket : String? = nil) : Void
      bucket ||= @default_bucket

      headers = {
        "Content-Type" => MIME.from_filename(target_name),
      }

      uploader = Awscr::S3::FileUploader.new(@client, Awscr::S3::FileUploader::Options.new(with_content_types: false))

      uploader.upload(bucket, target_name, file, headers)
    end

    def public_url(path : String, bucket : String? = nil) : String
      bucket ||= @default_bucket

      @public_url_pattern % {
        "path"   => path,
        "bucket" => bucket,
      }
    end

    def bucket_exists?(bucket : String)
      @client.head_bucket(bucket)
    rescue
      false
    end

    def file_exists?(name : String, bucket : String? = nil)
      bucket ||= @default_bucket

      return false unless bucket_exists?(bucket)

      all_names = [] of String

      @client.list_objects(bucket).each do |resp|
        resp.contents.each do |object|
          all_names << object.key
        end
      end

      all_names.includes?(name)
    end

    def file_delete(name : String, bucket : String? = nil)
      bucket ||= @default_bucket

      @client.delete_object(bucket, name)
    end
  end
end
