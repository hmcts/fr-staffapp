class ApplicationFormRepository
  attr_reader :application, :form_params, :form

  def initialize(application, form_params)
    @application = application
    @form_params = form_params
    @success = false
  end

  def process(form_name)
    form_class = format_form_class_name(form_name)
    @form = form_class.new(application.detail)
    update_form_attributes_and_save
    update_outcome
    @form
  end

  def success?
    @success
  end

  private

  def format_form_class_name(form_name)
    form_name = form_name.to_s.classify
    "Forms::Application::#{form_name}".constantize
  end

  def update_form_attributes_and_save
    @form.update(form_params)
    @success = @form.save
  end

  def continue_with_discretion_applied?
    @form.discretion_applied != false
  end

  def application_outcome_and_type(outcome, application_type)
    application.update(outcome: outcome, application_type: application_type)
  end

  def update_outcome
    return if continue_with_discretion_applied?

    application_outcome_and_type('none', 'none')
  end

end
