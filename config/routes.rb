require "sidekiq/web"
Rails.application.routes.draw do
	Sidekiq::Web.use Rack::Auth::Basic do |username, password|
		params = Rails.application.secrets[:sidekiq].with_indifferent_access
		sidekiq_user = ::Digest::SHA256.hexdigest(params[:username])
		sidekiq_password = ::Digest::SHA256.hexdigest(params[:password])

		login_hash = ::Digest::SHA256.hexdigest(username)
		password_hash = ::Digest::SHA256.hexdigest(password)
		ActiveSupport::SecurityUtils.secure_compare(login_hash, sidekiq_user) &
		ActiveSupport::SecurityUtils.secure_compare(password_hash, sidekiq_password)
	end
	mount Sidekiq::Web, at: "/sidekiq"
end
