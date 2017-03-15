class TimeSheetGrid
  include Datagrid

  scope do
    TimeSheet.order('time_sheets.id asc')
  end

  # 1.upto.31 do |n|
  #   column(n.to_s, header: n) do |asset|
  #     format(asset.id) do |value|
  #       n
  #     end
  #   end
  # end
end
