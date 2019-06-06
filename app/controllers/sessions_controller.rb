class SessionsController < ApplicationController
  def create
    # CREATE USER
    if params[:login]
      if params[:auth] && params[:auth][:id]
        user = User.create_facebook(params[:auth])
        user.add_role(:user) unless user.has_role?(:user)
        if user
          login = "new" unless user.company_id
          session[:user_id] = user.id

          render status: 200, json: {"status": "ok", "login": login}
        end
      end
    end

    # GET PAGES
    if params[:pages] && params[:data]
      Page.create_pages(params[:user_id], params[:data])
      render status: 200, json: {"status": "ok"}
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
