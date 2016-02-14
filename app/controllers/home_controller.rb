class HomeController < ApplicationController
	def index
		@message = "Welcome User"
		if current_user
			redirect_to dashboard_path
		end
	end

	def dashboard
		@message = "Dashboard"
	end
end
