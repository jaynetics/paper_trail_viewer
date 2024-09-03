require 'kaminari'
require 'ostruct'

module PaperTrailViewer
  module DataSource
    # Abstract superclass for version data sources.
    class Base
      def call(params, main_app)
        query = PaperTrailViewer::Query.new(params)
        relation = perform_query(query)
        versions_as_json = relation.map { |v| version_as_json(v, main_app) }

        {
          allowRollback: PaperTrailViewer.allow_rollback,
          hasNextPage:   versions_as_json.any? && !relation.last_page?,
          query:         query.to_h,
          versions:      versions_as_json,
        }
      end

      private

      def version_as_json(version, main_app)
        {
          **version.attributes.slice(*%w[id whodunnit event created_at]),
          changeset: changeset_for(version),
          object:    load_object(version),
          item_id:   version.item_id.to_s,
          item_type: version.item_type,
          item_url:  change_item_url(version, main_app),
          user_url:  user_url(version, main_app),
        }
      end

      def changeset_for(version)
        case version.event
        when 'create', 'update'
          version.changeset || {}
        when 'destroy'
          record = version.reify rescue nil
          return {} unless record

          record.attributes.each_with_object({}) do |changes, (k, v)|
            changes[k] = [v, nil] unless v.nil?
          end
        else
          raise ArgumentError, "Unknown event: #{version.event}"
        end
      end

      # Return the URL for the item represented by the +version+,
      # e.g. a Company record instance referenced by a version.
      def change_item_url(version, main_app)
        version_type = version.item_type.underscore.split('/').last
        main_app.try("#{version_type}_url", version.item_id)
      end

      def user_url(version, main_app)
        (path_method = PaperTrailViewer.user_path_method).present? &&
          (id = version.whodunnit).present? &&
          !id.start_with?('#') &&
          main_app.try(path_method, id) ||
          nil
      end

      def load_object(version)
        obj = version.object
        if obj.is_a?(String)
          PaperTrail.serializer.load(obj)
        elsif obj.is_a?(Hash)
          OpenStruct.new(obj)
        else
          obj
        end
      end
    end
  end
end

# backport deserialization fix for recent rubies
# https://github.com/paper-trail-gem/paper_trail/pull/1338
if PaperTrail::VERSION.to_s < '12.2.0'
  module PaperTrail::Serializers::YAML
    def load(string)
      ::YAML.respond_to?(:unsafe_load) ? ::YAML.unsafe_load(string) : ::YAML.load(string)
    end
  end
end
