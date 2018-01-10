require 'open_weather'

class WeatherMetricsService
	APPID = Rails.application.secrets[:open_weather_key]
	attr_reader :temp, :min_temp, :max_temp, :wind_speed,
				:city, :req_options

	def initialize(city_id, opts = {})
		@req_options = {units: 'metric', APPID: APPID}
		@req_options = @req_options.merge(opts)

		load_city(city_id)
	end

	def self.fetch(*args)
		fetcher = new(*args)
		fetcher.fetch!
	end
	def fetch!
		city_code = "#{city.name}, #{city.code}"
		response = OpenWeather::Current.city(city_code, req_options)
		handle_response(response)
	end

	private

	def load_city(city_id)
		@city = City.find_by!(id: city_id)
	end
	def handle_response(response)
		status_code = response['cod'].to_i

		if success_responce?(status_code)
			save_metric(response)
		else
			fail "APIWeatherError: code = #{status_code}, #{response['message']}"
		end
	end
	def save_metric(response)
		city.metrics.create!(prepare_metric(response))
	end
	def prepare_metric(response)
		{
			temp: response['main']['temp'],
			min_temp: response['main']['temp_min'],
			max_temp: response['main']['temp_max'],
			wind_speed: response['wind']['speed']
		}
	end
	def success_responce?(code)
		code == SUCCESS_CODE
	end
end