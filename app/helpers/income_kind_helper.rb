module IncomeKindHelper
  def income_kind_list
    # just array for index iteration
    [
      :wage, :net_profit, :child_benefit, :working_credit, :child_credit, :maintenance_payments, :jsa, :esa,
      :universal_credit, :pensions, :rent_from_cohabit, :rent_from_properties, :cash_gifts, :financial_support,
      :loans, :other_income, :none_of_the_above
    ]
  end

  def kind_checked(application, form, claimant, kind)
    return false if application.income_kind.blank?

    application.income_kind[claimant].include? t(kind, scope: [form.i18n_scope, 'kinds'])
  end
end
