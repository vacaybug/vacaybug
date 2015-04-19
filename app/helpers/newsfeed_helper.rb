module NewsfeedHelper
	def story_published story
		(story.user.followers.pluck(:id) + [story.user_id]).uniq.each do |user_id|
			puts user_id
			NewsfeedAssociation.create(user_id: user_id, story_id: story.id)
		end
	end
end
