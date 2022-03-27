class PaperTrailViewer::VersionsController < ActionController::Base
  # Return the queried versions as JSON.
  def index
    result = PaperTrailViewer.data_source.call(params, main_app)
    render json: result
  end

  # Roll back a change.
  def update
    result = PaperTrailViewer::Rollback.call(version_id: params[:id])
    render json: result
  end
end
