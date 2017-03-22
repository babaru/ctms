class ReportingController < ApplicationController
  def time_sheets
    @year = params[:calendar].split('-').first.to_i if params[:calendar]
    @month = params[:calendar].split('-').last.to_i if params[:calendar]
    @year ||= Time.current.year
    @month ||= Time.current.month
    @first_day = Time.new(@year, @month, 1)
    @last_day = Time.new(@year, @month, Time.days_in_month(@month, @year))

    respond_to do |format|
      format.html
    end
  end
end
