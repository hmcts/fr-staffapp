def around_stub(obj)
  id = obj.id
  obj.id = nil
  yield
  obj.id = id
end

def build_related_for_application(scope, method, application, evaluator)
  application.applicant ||= scope.send(method,
                                       evaluator.applicant_factory, *evaluator.applicant_traits,
                                       application: application, ni_number: evaluator.ni_number)

  application.detail ||= begin
    overrides = { application: application }
    [:fee, :date_received, :refund, :date_fee_paid, :probate, :jurisdiction, :emergency_reason].each do |field|
      value = evaluator.send(field)
      overrides[field] = value if value.present?
    end

    scope.send(method, evaluator.detail_factory,
               *evaluator.detail_traits, overrides)
  end

end

