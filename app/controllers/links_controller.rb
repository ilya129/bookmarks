class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:open]

  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :set_linkdomain, only: [:create, :open]
  before_action :set_shortlink, only: [:open]

  after_action :verify_authorized, except: [:open, :index]

  after_action :verify_policy_scoped, only: :index

  def open
    Link.increment_counter(:clicks, @link.id)
    redirect_to @link.url, status: :moved_permanently
  end

  def index
    @links = policy_scope(Link)
  end

  def show
    authorize @link
  end

  def new
    @link = Link.new
    authorize @link
  end

  def edit
    authorize @link
  end

  def create
    @link = Link.new(link_params)

    authorize @link

    @link.user = current_user
    @link.domain = @domain

    if @link.save && verify_recaptcha(model: @link)
      redirect_to @link, notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @link

    if @link.update(link_params)
      redirect_to @link, notice: 'Link was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @link

    @link.destroy
    redirect_to links_url, notice: 'Link was successfully destroyed.'
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:name, :url)
  end

  def set_shortlink
    name = params[:short_url]
    @link = Link.where(name: name, domain: @domain).take
  end

  def set_linkdomain
    @domain = nil
  end
end

