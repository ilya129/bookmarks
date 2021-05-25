class LinkPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    update?
  end

  def show?
    update?
  end

  def update?
    user_is_owner?(record) || user.admin?
  end

  class Scope < Scope
    def resolve
      if user.present?
        user.admin? ? scope.all : scope.where(user: user)
      end
    end
  end

  private

  def user_is_owner?(link)
    user.present? && (link.try(:user) == user)
  end
end
