class ItemsController < ApplicationController
  before_filter :load_standup
  around_filter :standup_timezone

  def create
    @item = Item.new(params[:item])
    if @item.save
      redirect_to @item.post ? edit_post_path(@item.post) : standup_path(@item.standup)
    else
      render 'items/new'
    end
  end

  def new
    @standup = Standup.find_by_id(params[:standup_id])
    options = (params[:item] || {}).merge({post_id: params[:post_id], author: session[:username]})
    options.reverse_merge!(date: Time.zone.today)
    @item = @standup.items.build(options)
    render_custom_item_template @item
  end

  def index
    @standup = Standup.find_by_id(params[:standup_id])
    events = Item.events_on_or_after(Time.zone.today, @standup)
    @items = @standup.items.orphans.merge(events)
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to request.referer
  end

  def edit
    @item = Item.find(params[:id])
    render_custom_item_template @item
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    if @item.save
      redirect_to params[:redirect_to] || @standup
    else
      render_custom_item_template @item
    end
  end

  def presentation
    events = Item.events_on_or_after(Time.zone.today, @standup)
    @items = @standup.items.orphans.merge(events)
    render layout: 'deck'
  end

  private

  def render_custom_item_template(item)
    if item.possible_template_name && template_exists?(item.possible_template_name)
      render item.possible_template_name
    else
      render "items/new"
    end
  end

  def load_standup
    @standup = Standup.find_by(id: params[:id])

    if params[:standup_id].present?
      standup = Standup.find(params[:standup_id])
    elsif params[:item][:standup_id].present?
      standup = Standup.find(params[:item][:standup_id])
    else
      standup = Item.find(params[:id]).standup
    end

    @standup = StandupPresenter.new(standup)
  end

  def standup_timezone(&block)
    return yield unless @standup
    Time.use_zone(@standup.time_zone_name, &block)
  end
end
