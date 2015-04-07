class Comment < ActiveRecord::Base
	require 'rails_rinku'
	attr_accessible :user_id, :story_id, :text
	belongs_to :user
	belongs_to :story

	before_save :escape_text

	def as_json(options={})
		options[:methods] ||= [:user]
		super(options)
	end

	private

	def escape_text
		self.text = Rinku.auto_link self.text
	end
end
