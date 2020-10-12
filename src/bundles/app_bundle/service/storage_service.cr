require "awscr-s3"
require "random"

module App
  class StorageService
    def initialize(@client : Awscr::S3::Client, @default_bucket : String)
    end

    def generate_random_name(ext : String)
      Random::Secure.hex + ".#{ext}"
    end

    def upload_file(file : File, target_name : String, bucket : String? = nil) : Void
      bucket ||= @default_bucket

      uploader = Awscr::S3::FileUploader.new(@client)

      uploader.upload(bucket, target_name, file)
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
