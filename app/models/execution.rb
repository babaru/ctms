class Execution < ApplicationRecord
  belongs_to :scenario
  belongs_to :plan

  class << self

  def results
    ExecutionResult.enums.map{ |k,v| [I18n.t("execution_results.#{k}"),v] }
  end

  def result_names
    ExecutionResult.enums.map{ |k,v| [v, I18n.t("execution_results.#{k}")] }.to_h
  end

  end
end
