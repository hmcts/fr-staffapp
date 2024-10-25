class UpdateIncomeKindPartnerValue < ActiveRecord::Migration[7.2]
  def change
    Application.all.each do |application|
      unless application.income_kind.blank? || application.income_kind[:partner].blank?
        if application.income_kind[:partner].include?('Rent from anyone living with the applicant') || application.income_kind[:partner].include?('Rent from other properties the applicant owns')
          application.income_kind[:partner].each_with_index do |value, index|
            if value == 'Rent from anyone living with the applicant'
              application.income_kind[:partner][index] = 'Rent from anyone living with the partner'
            elsif value == 'Rent from other properties the applicant owns'
              application.income_kind[:partner][index] = 'Rent from other properties the partner owns'
            end
          end
        end
        application.save!
      end
    end

    OnlineApplication.all.each do |application|
      unless application.income_kind.blank? || application.income_kind['partner'].blank?
        if application.income_kind['partner'].include?('Rent from anyone living with the applicant') || application.income_kind['partner'].include?('Rent from other properties the applicant owns')
          application.income_kind['partner'].each_with_index do |value, index|
            if value == 'Rent from anyone living with the applicant'
              application.income_kind['partner'][index] = 'Rent from anyone living with the partner'
            elsif value == 'Rent from other properties the applicant owns'
              application.income_kind['partner'][index] = 'Rent from other properties the partner owns'
            end
          end
        end
        application.save!
      end
    end

    Application.all.each do |application|
      unless application.income_kind.blank? || application.income_kind[:applicant].blank?
        if application.income_kind[:applicant].include?('Rent from anyone living with the partner') || application.income_kind[:applicant].include?('Rent from other properties the partner owns')
          application.income_kind[:applicant].each_with_index do |value, index|
            if value == 'Rent from anyone living with the partner'
              application.income_kind[:applicant][index] = 'Rent from anyone living with the applicant'
            elsif value == 'Rent from other properties the partner owns'
              application.income_kind[:applicant][index] = 'Rent from other properties the applicant owns'
            end
          end
        end
        application.save!
      end
    end

    OnlineApplication.all.each do |application|
      unless application.income_kind.blank? || application.income_kind['applicant'].blank?
        if application.income_kind['applicant'].include?('Rent from anyone living with the partner') || application.income_kind['partner'].include?('Rent from other properties the partner owns')
          application.income_kind['applicant'].each_with_index do |value, index|
            if value == 'Rent from anyone living with the partner'
              application.income_kind['applicant'][index] = 'Rent from anyone living with the applicant'
            elsif value == 'Rent from other properties the partner owns'
              application.income_kind['applicant'][index] = 'Rent from other properties the applicant owns'
            end
          end
        end
        application.save!
      end
    end
  end
end
