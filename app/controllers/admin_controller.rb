class AdminController < ApplicationController
	before_action :auth, :has_company, :current_user, :current_company

	let :super_admin, :all
  let :sub_free, [:stats, :posts, :settings]
  let :sub_basic, [:stats, :posts, :settings, :settings_pages, :settings_team]
  let :sub_pro, :sub_enterprise, [:stats, :posts, :campaign, :settings, :settings_pages, :settings_team]

	layout 'admin'

  def stats
    company_data
  end

  def campaign
    company_data

    if request.post?
      if Page.find_by(id: params[:campaign][:page_id])
        campaign = params[:campaign]
        tags = campaign[:tags].delete(' ').split(',')
        Campaign.create(page_id: campaign[:page_id], title: campaign[:name], compare: campaign[:compare], tags: tags, start_date: campaign[:start_date], end_date: campaign[:end_date] )

        redirect_to admin_campaign_path and return
      end
    end
  end
  
  def posts
    company_data
  end

  def settings
    company_data
  end

  def settings_pages
    company_data
  end

  def settings_team
    company_data
  end
  
  private
    def company_data
      @team = current_company.users
      if current_user.has_role?(:super_admin)
        @pages = Page.all.order("name asc")
      else
        @pages = @team.map{|u| u.pages}.flatten
      end
    end
end
