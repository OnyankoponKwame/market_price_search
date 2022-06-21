class SearchConditionsController < ApplicationController
  skip_before_action :require_login

  def create
    search_word = params[:keyword]
    # nonzeroは0のときにnilを返し、そうでない場合は自身を返す
    price_min = params[:price_min].to_i.nonzero?
    price_max = params[:price_max].to_i.nonzero?

    search_condition = SearchCondition.find_by(keyword: search_word, price_min:, price_max:)
    if search_condition
      flag = search_condition.cron_flag
      search_condition.update!(cron_flag: !flag)
    else
      search_condition = SearchCondition.create(keyword: search_word, price_min:, price_max:, negative_keyword:, include_title_flag:, cron_flag: true)
    end
    render json: { cron_flag: search_condition.cron_flag }
  end
end
