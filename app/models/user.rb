class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :async
         

        validate :email_is_unique, on: :create
        validate :subdomain_is_unique, on: :create
        validates :company_name, presence: true, length: {maximum: 50}
        validates :company_website, length: {maximum: 50}
        validates :accent_color, length: {maximum: 7}
        validates :title, presence: true, length: {maximum: 50}
        validates :subtitle, presence: true, length: {maximum: 100}
        after_validation :create_tenant
        after_create :create_account
        after_create :add_role_to_user

        # def devise_confirmable?
        #     false
        # end
      	  

     	private

     	#Email should be unique in Account model

     	def email_is_unique
     		#Do not validate email if errors are already present.
     		return false unless self.errors[:email].empty?

     		unless Account.find_by_email(email).nil?
     			errors.add(:email, " is already taken")
     		end
     	end

        def subdomain_is_unique
            if subdomain.present?
                unless Account.find_by_subdomain(subdomain).nil?
                    errors.add(:subdomain, "is already taken")
                end
                if Apartment::Elevators::Subdomain.excluded_subdomains.include?(subdomain)
                    errors.add(:subdomain, "is not a valid subdomain")
                end
            end
        end

     	def create_account
     		account = Account.new(:email => email, :subdomain => subdomain)
     		account.save!
     	end

        def create_tenant
            return false unless self.errors.empty?
                #If its a new record, create the tenant
                #For Edits, do not create
                if self.new_record?
                    Apartment::Tenant.create(subdomain)
                end
                #Change schema to the tenant
                Apartment::Tenant.switch!(subdomain)
        end

        #Add default roles for user
        def add_role_to_user
            if created_by_invite?
                add_role :app_user
            else
                add_role :app_admin
            end
        end
end
