StripeEvent.configure do |events|

	#Subscription failed/deleted
	events.subscribe 'customer.subscription.deleted' do |event|
		#Delete the customers subscription from Account Model
		subscription = event.data.object
		customer_id = subscriptuon.customer

		#Move to account model
		account = Account.find_by_customer_id(customer_id)
		account.stripe_plan_id = ''
		# account.customer is unchanged
		account.active_until = Time.at(0).to_datetime
		account.save!
	end

	#Charge succeeded for subscription
	events.subscribe 'customer.subscription.updated' do |event|
		#Called for any change on the subscription object
		subscription = event.data.object
		#Move to account model
		customer_id = subscription.customer
		account = Account.find_by_customer_id(customer_id)
		account.stripe_plan_id = subscription.plan.id
		# account.customer is unchanged
		account.active_until = Time.at(subscription.current_period_end).to_datetime
		account.save!
	end

  # events.subscribe 'charge.failed' do |event|
  #   # Define subscriber behavior based on the event object
  #   event.class       #=> Stripe::Event
  #   event.type        #=> "charge.failed"
  #   event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
  # end

  # events.all do |event|
  #   # Handle all event types - logging, etc.
  # end
end