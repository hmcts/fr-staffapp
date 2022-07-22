module Query
  class DeletedApplications
    def initialize(user)
      @user = user
    end

    def find(filter = {})
      list = @user.office.applications.deleted.order(deleted_at: :desc)
      list = list.joins(:detail).where(details: filter) if filter && filter[:jurisdiction_id].present?
      list
    end
  end
end
