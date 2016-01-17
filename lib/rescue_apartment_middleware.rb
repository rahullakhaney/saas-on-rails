 module RescueApartmentMiddleware

  def call(*args)
    begin
      #Call Apartment Middleware to do its job
      super
    rescue Apartment::TenantNotFound => e
      ap "Apartment::TenantNotFound -> Exception occured"
      ap e.message
      return [404, {"Content-Type" => "text/html"}, ["#{File.read(Rails.root.to_s + '/public/404.html')}"] ]

    end
  end

 end