require "../../src/bundles/app_bundle/service/storage_service"

class StorageServiceMock < App::StorageService
  def upload_file(file : File, target_name : String, bucket : String? = nil) : Void
    5 * 5
  end

  def bucket_exists?(bucket : String)
    false
  end

  def file_exists?(name : String, bucket : String? = nil)
    false
  end

  def file_delete(name : String, bucket : String? = nil)
    true
  end
end
