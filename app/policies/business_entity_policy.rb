class BusinessEntityPolicy < BasePolicy
  def index?
    admin?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def deactivate?
    admin?
  end

  def confirm_deactivate?
    admin?
  end
end
