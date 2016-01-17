class SessionsController < Devise::SessionsController
	def new
		if request.subdomain.blank? || request.subdomain == "www"
			flash[:notice] = "Access Restricted"
			redirect_to :root
		else
			super
		end
	end
end