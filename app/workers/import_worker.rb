class ImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: "ImportWorker"
  
  def perform(organization_id)
    Organization.import_file organization_id
  end
end