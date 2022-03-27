module PaperTrailViewer
  Query = Struct.new(*%i[event filter item_id item_type page per_page version_class]) do
    def initialize(params)
      self.event      = params[:event].presence_in(%w[create update destroy])
      self.filter     = (params[:filter].presence if params[:filter] != '%%')
      self.item_id    = params[:item_id].presence
      self.item_type  = params[:item_type].presence
      self.page       = params[:page].to_i.clamp(1, 1000)
      self.per_page   = params[:per_page].presence&.to_i&.clamp(1, 1000) || 50

      # If an item_type is given, try to see if it uses a custom version class.
      if item_type
        begin
          item_class = item_type.classify.constantize
          self.version_class = item_class.version_class_name
        rescue NameError, NoMethodError
          # We might be looking at a model that is deleted or no longer versioned.
          # Ignore and give it a try with the default version class.
        end
      end
    end
  end
end
