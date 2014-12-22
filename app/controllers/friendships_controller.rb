class FriendshipsController < ActionController::Base
  def create
    current_user.add_friend(params[:friend_id])
    redirect_to root_url
  end

  def destroy
    current_user.remove_friend(params[:friend_id])
    redirect_to root_url
  end
end
