class ProducerInfoCronWorker
  include Sidekiq::Worker

  def perform(*args)
    # Crawling country and logo_image_url via calling get
    Producer.all.each do |row|
      country = row.country
      logo_image_url = row.logo_image_url
      
      unless row.url.empty?
        bp_response = Typhoeus::Request.get(
          row.url+'/bp.json',
          followlocation: true,
          timeout: 3
        )
        
        if bp_response.code == 200
          begin
            bp_json = JSON.parse bp_response.body
            if bp_json.has_key?("org") 
              if bp_json["org"].has_key?("location") and
                  bp_json["org"]["location"].has_key?("country")
                country = bp_json["org"]["location"]["country"]
              end
    
              if bp_json["org"].has_key?("branding")
                if bp_json["org"]["branding"].has_key?("logo_svg") and
                    (not bp_json["org"]["branding"]["logo_svg"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_svg"]
                elsif bp_json["org"]["branding"].has_key?("logo_1024") and
                    (not bp_json["org"]["branding"]["logo_1024"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_1024"]
                elsif bp_json["org"]["branding"].has_key?("logo_256") and
                    (not bp_json["org"]["branding"]["logo_256"].empty?)
                  logo_image_url = bp_json["org"]["branding"]["logo_256"]
                end
              end
            end
            row.update(
              country: country,
              logo_image_url: logo_image_url
            )
          rescue JSON::ParserError
            # Do nothing.
          end
        end
      end
    end
  end
end
