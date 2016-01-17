class SubscriptionsController < ApplicationController
	before_action :authenticate_user!
	before_action :authorize_user

	def new
		@plans = Plan.all
	end

	def index
		@account = Account.find_by_email(current_user.email)
	end

	def edit
		@account = Account.find(params[:id])
		@plans = Plan.all
	end

	def cancel_subscription
		email = current_user.email
		current_account = Account.find_by_email(current_user.email)
		customer_id = current_account.customer_id
		current_plan = current_account.stripe_plan_id

		if current_plan.blank?
			raise "No plan found to unsubscribe/cancel"
		end
		#Fetch customer from stripe
		customer = Stripe::Customer.retrieve(customer_id)
		#Get customer's subscriptions
		subscriptions = customer.subscriptions
		#Find the subscription that we want to cancel
		current_subscribed_plan = subscriptions.data.find { |o| o.plan.id == current_plan }

		if current_subscribed_plan.blank?
			raise "Subscription not found!!"
		end

		#Delete it
		current_subscribed_plan.delete ({:at_period_end => true})

		#Update account model
		save_account_details(current_account, "", customer_id, Time.at(0).to_datetime)

		flash[:info] = "Subscription cancelled successfully"

	rescue => e
		redirect_to "/subscriptions", :flash => {:error => e.message}

	end

	def update_card

	end

	def update_card_details
		#Take the token given by stripe and set it for customer 
		token = params[:stripeToken]
		#Get customer_id
		current_account = Account.find_by_email(current_user.email)
		customer_id = current_account.customer_id

		#Get customer from stripe
		customer = Stripe::Customer.retrieve(customer_id)
		#Set new card token
		customer.source = token
		customer.save

		redirect_to "/subscriptions", :notice => "Card updated successfully"

	rescue => e
		redirect_to :action => "update_card", :flash => { :error => e.message }

	end

	def create
		
		token = params[:stripeToken]
		plan = params[:plan][:stripe_id]
		email = current_user.email
		current_account = Account.find_by_email(current_user.email)
		customer_id = current_account.customer_id
		current_plan = current_account.stripe_plan_id

		if customer_id.nil?
			#New Customer -> Create Customer

			@customer = Stripe::Customer.create(
			:source => token,
			:plan => plan,
			:email => email
		)
			subscriptions = @customer.subscriptions
			@subscribed_plan = subscriptions.data.find { |o| o.plan.id == plan }
		else
			#Customer Exists
			#GEt customer from stripe
			@customer = Stripe::Customer.retrieve(customer_id)
			#Get Current Plan if any
			@subscribed_plan = create_or_update_subscription(@customer, current_plan, plan)

		end

		# Get current period end - This is a unix timestamp
		current_period_end = @subscribed_plan.current_period_end
		#Converting unix timestamp into Rails friendly timestamp
		active_until = Time.at(current_period_end).to_datetime

		save_account_details(current_account, plan, @customer.id, active_until)


		redirect_to :root, :notice => "Successfully subscribed to a plan"

	rescue => e
		redirect_to :back, :flash => { :error => e.message }
	end

	

	def save_account_details(account, plan, customer_id, active_until)
		#Customer created with a valid subscription
		#So, Update Account Model

		account.stripe_plan_id = plan
		account.customer_id = customer_id
		account.active_until = active_until
		account.save!
	end

	def create_or_update_subscription(customer, current_plan, new_plan)
		subscriptions = customer.subscriptions
		#Get current subscription
		current_subscription = subscriptions.data.find{ |o| o.plan.id == current_plan }

		if current_subscription.blank?
			#No Current Subscription
			#Maybe the customer unsubscribed or the card was declined
			#Create new subscription for existing customer
			subscription = customer.subscriptions.create({:plan => new_plan})
		else
			#Exisitng subscription found
			#Must be an upgrade or downgrade
			#Update existing subscription with new plan
			current_subscription.plan = new_plan
			subscription = current_subscription.save
		end

		return subscription
	end

	#Authorize user or raise exception
	def authorize_user
		authorize! :manage, :subscriptions
	end

end
