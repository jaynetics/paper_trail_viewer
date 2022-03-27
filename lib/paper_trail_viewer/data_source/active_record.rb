require 'kaminari'

module PaperTrailViewer::DataSource
  # The default data source. Queries version records via ActiveRecord.
  # See DataSource::Bigquery::Adapter for how to implement another source.
  class ActiveRecord < Base
    def initialize(version_class: 'PaperTrail::Version')
      @version_class = version_class
    end

    # @param [PaperTrailViewer::Query]
    def perform_query(q)
      version_class = q.version_class || @version_class
      versions = version_class.is_a?(String) ? version_class.constantize : version_class

      if 'object_changes'.in?(versions.column_names)
        # Ignore blank versions that only touch updated_at or untracked fields.
        versions = versions.where.not(object_changes: '')
        versions = versions.where('object_changes LIKE ?', "%#{q.filter}%") if q.filter.present?
      elsif 'object'.in?(versions.column_names)
        versions = versions.where('object LIKE ?', "%#{q.filter}%") if q.filter.present?
      end

      versions = versions.where(item_type: q.item_type) if q.item_type.present?
      versions = versions.where(item_id: q.item_id) if q.item_id.present?
      versions = versions.where(event: q.event) if q.event.present?

      versions.order('created_at DESC, id DESC').page(q.page).per(q.per_page)
    end
  end
end
