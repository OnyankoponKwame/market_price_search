class SearchConditionsController < ApplicationController
  def create
    search_condition = SearchCondition.find_by(keyword: params[:keyword])
    if search_condition
      flag = search_condition.cron_flag
      search_condition.update(cron_flag: !flag)
    else
      search_condition = SearchCondition.create(keyword: params[:keyword], cron_flag: true)
    end
    render json: { cron_flag: search_condition.cron_flag }
  end
end
