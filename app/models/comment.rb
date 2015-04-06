class Comment < ActiveRecord::Base
	attr_accessible :user_id, :story_id, :text
	belongs_to :user
	belongs_to :story

	def as_json(options={})
		options[:methods] ||= [:user]
		super(options)
	end
end
