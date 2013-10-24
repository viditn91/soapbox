class FollowingsController < ApplicationController
  before_action :set_following, only: [:show, :edit, :update, :destroy]


  def create
    @following = current_user.followings.build(following_params)

    respond_to do |format|
      if @following.save
        followee = User.find(params[:followee_id])
        #FIXME_AB: Should avoid saving html format in db. Just save pointers and generate html when you want to display. We may change the way we display notification in future, so in that case we won't have to bother about what we have in DB
        notification = '<a>' + current_user.name + '</a>  started following you' 
        followee.notifications << Notification.new(content: notification)
        format.html { redirect_to :back, notice: "You are now following #{ @following.followee.firstname } " }
        format.json { render action: 'show', status: :created, location: @following }
      else
        format.html { redirect_to current_user, notice: "An error occured while following #{ @following.followee } " }
        format.json { render json: @following.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @following.destroy
    respond_to do |format|
      format.html { redirect_to  :back, notice: "You are not following #{ @following.followee.firstname } now" }
      format.json { head :no_content }
    end
  end

  protected

    def set_following
      @following = current_user.followings.find_by(followee_id: params[:followee_id])
    end

    def following_params
      params.permit(:followee_id)
    end
end
