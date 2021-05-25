class UserPolicy < ApplicationPolicy
  def show?
    user.present? && (user == record || user.admin?)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

