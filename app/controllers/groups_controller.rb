class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:update, :edit]

  def new
    @group = Group.new
  end

  def index
    @groups = Group.all
    @book = Book.new
  end

  def show
    @group = Group.find(params[:id])
    @book = Book.new
  end

  def create
    @group = Group.new(group_params)
    @group.owner_id = current_user.id
    @group.users << current_user
    if @group.save
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def join
    @group = Group.find(params[:group_id])
    unless @group.users.include?(current_user)
      @group.users << current_user
      redirect_to request.referer
    else
      @groups = Group.all
      render :index
    end
  end

  def leave
    @group = Group.find(params[:group_id])
    @group.users.destroy(current_user)
      redirect_to request.referer
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path
    else
      render :edit
    end
  end

  def new_mail
    @group = Group.find(params[:group_id])
  end

  def send_mail
    @group = Group.find(params[:group_id])
    group_users = @group.users
    @mail_title = params[:mail_title]
    @mail_content = params[:mail_content]
    ContactMailer.send_mail(@mail_title, @mail_content, group_users).deliver
    # 実際の送信を担うのはdeliverメソッド
  end

  private

  def group_params
    params.require(:group).permit(:name, :introduction, :group_image)
  end

  def ensure_correct_user
    @group = Group.find(params[:id])
    unless @group.owner_id == current_user.id
      redirect_to groups_path
    end
  end
end
