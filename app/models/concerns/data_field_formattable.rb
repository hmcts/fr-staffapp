module DataFieldFormattable
  extend ActiveSupport::Concern

  def format_the_dates?(date_attr_name)
    date = send(date_attr_name.to_s)
    day = send(:"day_#{date_attr_name}")
    month = send(:"month_#{date_attr_name}")
    year = send(:"year_#{date_attr_name}")

    !(day.blank? && month.blank? && year.blank? && date.present?)
  end

  def format_dates(date_attr_name)
    instance_variable_set(:"@#{date_attr_name}", concat_dates(date_attr_name).to_date)
  rescue ArgumentError
    instance_variable_set(:"@#{date_attr_name}", concat_dates(date_attr_name))
  end

  def concat_dates(date_attr_name)
    day = send(:"day_#{date_attr_name}")
    month = send(:"month_#{date_attr_name}")
    year = send(:"year_#{date_attr_name}")
    return '' if day.blank? || month.blank? || year.blank?

    "#{day}/#{month}/#{year}"
  end

  def day_date_received
    return @day_date_received if @day_date_received
    date_received&.day
  end

  def month_date_received
    return @month_date_received if @month_date_received
    date_received&.month
  end

  def year_date_received
    return @year_date_received if @year_date_received
    date_received&.year
  end

  def day_date_of_death
    return @day_date_of_death if @day_date_of_death
    date_of_death&.day
  end

  def month_date_of_death
    return @month_date_of_death if @month_date_of_death
    date_of_death&.month
  end

  def year_date_of_death
    return @year_date_of_death if @year_date_of_death
    date_of_death&.year
  end

  def day_date_fee_paid
    return @day_date_fee_paid if @day_date_fee_paid
    date_fee_paid&.day
  end

  def month_date_fee_paid
    return @month_date_fee_paid if @month_date_fee_paid
    date_fee_paid&.month
  end

  def year_date_fee_paid
    return @year_date_fee_paid if @year_date_fee_paid
    date_fee_paid&.year
  end

  def format_probate
    return if probate
    self.date_of_death = nil
    self.deceased_name = nil
  end

end
