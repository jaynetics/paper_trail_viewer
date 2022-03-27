module PaperTrailViewer::Rollback
  def self.call(version_class: PaperTrail::Version, version_id:)
    PaperTrailViewer.allow_rollback or raise 'Rollback not allowed'

    version = version_class.find(version_id)

    if version.event == 'create'
      version.item_type.constantize.find(version.item_id).destroy!
      Result.new(true, 'Rolled back newly-created record by destroying it.')
    else
      version.reify.save!
      Result.new(true, 'Rolled back changes to this record.')
    end

  rescue StandardError => e
    Result.new(false, "#{e.class}: #{e.message}")
  end

  Result = Struct.new(:success, :message)
end
