class ApplicationController < ActionController::Base
  def render_status(status)
    render plain: '#{status.to_s.titleize}', status: status
  end
end
