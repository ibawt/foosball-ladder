class UsersController < ApplicationController
  def index
    if params[:team_id]
      @users = User.where('team_id = ?', params[:team_id])
    else
      @users = User.all
    end
    respond_to do |format|
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find( params[:id] )

    respond_to do |format|
      format.json { render json: @user }
    end
  end
end
