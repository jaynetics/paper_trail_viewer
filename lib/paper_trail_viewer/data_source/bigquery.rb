module PaperTrailViewer::DataSource
  class Bigquery < Base
    def initialize(project_id:, credentials:, table:)
      require 'google/cloud/bigquery'

      @bigquery = Google::Cloud::Bigquery.new(
        project_id:  project_id,
        credentials: credentials,
      )
      @table = table
    end

    # @param [PaperTrailViewer::Query]
    def perform_query(q)
      # https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax
      bigquery_result = @bigquery.query(<<~SQL, max: q.per_page)
        SELECT   *
        FROM     `#{@table}`
        # Ignore blank versions that only touch updated_at or untracked fields.
        WHERE    object_changes != ''
        #{"AND   item_type = '#{q.item_type}'"        if q.item_type.present?}
        #{"AND   item_id = #{q.item_id}"              if q.item_id.present?}
        #{"AND   event = '#{q.event}'"                if q.event.present?}
        #{"AND   object_changes LIKE '%#{q.filter}%'" if q.filter.present?}
        ORDER BY created_at DESC, id DESC
        # Paginate via OFFSET.
        # LIMIT must be greater than `max:` or result#next? is always false.
        LIMIT    #{q.per_page + 1} OFFSET #{(q.page - 1) * q.per_page}
      SQL

      Adapter.new(bigquery_result)
    end

    Adapter = Struct.new(:bigquery_result) do
      # PaperTrail::Version::ActiveRecord_Relation compatibility method
      def map
        bigquery_result.map { |row| yield PaperTrail::Version.new(row) }
      end

      # Kaminari compatibility method
      def last_page?
        !bigquery_result.next?
      end
    end
  end
end
