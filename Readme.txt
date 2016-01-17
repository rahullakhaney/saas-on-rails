#Seeding Plan table

Stripe::Plan.retrieve("plan-free")
Stripe::Plan.retrieve("plan-elite")
Stripe::Plan.retrieve("plan-uber")

Plan.create(:stripe_id => p1.id, :name => p1.name, :price => p1.amount, :interval => p1.interval)