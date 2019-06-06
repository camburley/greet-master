class HomeController < ApplicationController
  def index
  end

  def api_documentation
  end

  def company
    redirect_to root_path unless current_user

    if request.post?
      # CREATE COMPANY
      if params[:company][:code] && current_user
        respond_to do |format|
          if current_user.company_id
            format.html { redirect_to sign_in_path, notice: 'You already have a company.' }
          else
            company = Company.find_by(code: params[:company][:code])
            current_user.update_attributes(company_id: company.id)

            format.html { redirect_to admin_settings_path, notice: 'Successfully joined company.' }
          end
        end
      elsif params[:company] && current_user
        unless current_user.company_id
          @company = Company.create_company(params[:company])
          user = User.find_by_id(current_user)
          user.company_id = @company.id
          user.save!
        end

        respond_to do |format|
          if @company.save
            format.html { redirect_to admin_settings_path, notice: 'Company was successfully created.' }
          else
            format.html { redirect_to sign_in_path, notice: 'You already have a company.' }
          end
        end
      end
    end
  end
end
