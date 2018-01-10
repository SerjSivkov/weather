class City < ApplicationRecord
	has_many :metrics

	# после добавления нового города запускается задача, переходила в redis, sidekiq и запуск процессов
	after_commit :fetch_weather_data, on: [:create]

	def current_weather
		metrics.last
	end

	private

	def fetch_weather_data
		WeatherMetricsService.delay.fetch(id)
	end
end
