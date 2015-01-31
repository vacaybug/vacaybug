class StaticController < ActionController::Base
	def guide
		render 'static/guide'
	end

	def follower
		render 'static/follower'
	end

	def following
		render 'static/following'
	end

	def login
		render 'static/login'
	end

	def signup
		render 'static/signup'
	end

	def message
		render 'static/message'
	end

	def search
		render 'static/search'
	end

	def search2
		render 'static/search2'
	end

	def home
		render 'static/home'
	end

	def privacy
		render 'static/privacy'
	end

	def about
		render 'static/about'
	end

	def terms
		render 'static/terms'
	end
end
