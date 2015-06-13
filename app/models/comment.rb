require 'rails_rinku'
require 'sanitize'

class Comment < ActiveRecord::Base

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
		self.text = Rinku.auto_link(self.text, :all, 'target="_blank"')
		self.text =	Sanitize.fragment(self.text,
			:elements => ['a'],
		 	:attributes => {
		    	'a'    => ['href', 'target'],
		  	},
		)
	end
end
