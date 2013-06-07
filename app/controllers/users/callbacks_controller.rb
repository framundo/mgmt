class Users::CallbacksController < Devise::OmniauthCallbacksController

  def github
    auth = request.env["omniauth.auth"]
    orgs = Github.orgs.list(user: auth.info.name).map {|o| o.login.downcase}
    unless orgs.include?(organization_name.downcase)
      return redirect_to root_path, :flash => { :error => t('errors.unauthorized', organization: organization_name) } 
    end
    @user = User.where(provider: auth.provider, uid: auth.uid).first
    @user = User.create!(user_attributes(auth)) unless @user
    sign_in_and_redirect(@user, event: :authentication)
    set_flash_message(:notice, :success, :kind => "Github") if is_navigational_format?
  end

  private

    def user_attributes(auth)
      {
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email,
        login: auth.info.nickname,
        token: auth.credentials.token,
        gravatar_id: auth.extra.raw_info.gravatar_id,
        organization_avatar: fetch_organization_avatar(auth.credentials.token)
      }
    end

    def fetch_organization_avatar(token)
      github = Github.new(oauth_token: token)
      organization = github.orgs.get(organization_name)
      organization.avatar_url
    end

    def organization_name
      AppConfiguration[:github].organization
    end

end