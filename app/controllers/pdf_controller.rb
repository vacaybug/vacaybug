class PdfController < AbstractController::Base
	include AbstractController::Rendering
	include AbstractController::Helpers
	include AbstractController::Translation
	include AbstractController::AssetPaths
	include Rails.application.routes.url_helpers
	helper ApplicationHelper
	self.view_paths = "app/views"

	def protect_against_forgery?
      false
    end



	# Uncomment if you want to use helpers 
	# defined in ApplicationHelper in your views
	# helper ApplicationHelper

	# Make sure your controller can find views
	self.view_paths = "app/views"

	# You can define custom helper methods to be used in views here
	# helper_method :current_admin
	# def current_admin; nil; end

	def show
		render template: "static/guidepdf"
	end
end
