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
end
