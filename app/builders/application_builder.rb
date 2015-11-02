class ApplicationBuilder

  attr_reader :application, :reference

  def initialize(current_user)
    @user = current_user
  end

  def create
    Application.create(
      office_id: @user.office_id,
      user_id: @user.id,
      reference: generate_reference,
      applicant: build_applicant,
      detail: build_details
    )
  end

  private

  def generate_reference
    entity_code = @user.office.entity_code
    current_year = Time.zone.now.strftime('%y')
    code_and_year = "#{entity_code}-#{current_year}"
    counter = Application.where('reference like ?', "#{code_and_year}-%").count + 1

    "#{code_and_year}-#{counter}"
  end

  def build_applicant
    Applicant.new
  end

  def build_details
    Detail.new(jurisdiction_id: @user.jurisdiction_id)
  end
end
