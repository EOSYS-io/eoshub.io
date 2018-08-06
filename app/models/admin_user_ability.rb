class AdminUserAbility
  include CanCan::Ability

  def initialize(admin_user)
    case AdminUser.roles[admin_user.role]
    when AdminUser.roles[:newbie]
      cannot :read, :all
      can :authorize, AdminUser
    when AdminUser.roles[:admin]
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :manage, :all
      cannot :manage, AdminUser
    when AdminUser.roles[:super_admin]
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      cannot :authorize, AdminUser
      can :manage, :all
    else
      cannot :read, :all
    end
  end
end