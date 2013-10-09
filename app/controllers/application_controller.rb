class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  protect_from_forgery

  rescue_from 'ActionController::UnknownFormat' do |exception|
    render :json => exception, :status => :not_acceptable
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render :json => exception, :status => :not_found
  end
end
