class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :current_page

  require 'resolv-replace'

  private
    def auth
    	return redirect_to root_path unless !!current_user
    end

    def has_company
    	return redirect_to create_company_path unless !!current_company
    end

    def current_user
    	@current_user ||= User.find_by(id: session[:user_id]) if session[:user_id] && User.find_by(id: session[:user_id])
    end

    def current_company
      @current_company ||= Company.find_by(id: current_user.company_id) if current_user && current_user.company_id
    end
end
