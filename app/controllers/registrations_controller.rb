class RegistrationsController < Devise::RegistrationsController
	
	def new
		if request.subdomain.blank? || request.subdomain == "www"
			super
		else
			flash[:notice] = "Access Restricted"
			redirect_to :root
		end
	end

	protected

	def after_sign_up_path_for(resource)
    #'/an/example/path' # Or :prefix_to_your_route

    new_user_session_url(subdomain: resource.subdomain)
    flash[:info] = "Please check your mail for a confirmation link"

  end

    def after_inactive_sign_up_path_for(resource)
        new_user_session_url(subdomain: resource.subdomain)
   end

   def update_resource(resource, params)
    resource.update_without_password(params)
  end

   
end