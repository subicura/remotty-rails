class Remotty::Users::SessionsController < Devise::SessionsController
  include Remotty::Users::BaseController
  
  wrap_parameters :user, include: [:email, :password]
  skip_before_filter :verify_signed_out_user, only: :destroy

  # POST /resource/sign_in
  # email과 password로 로그인
  # 새로운 토큰 생성
  #
  # ==== return
  # * +success+ - 로그인 후 user with token json return
  # * +failure+ - unauthorized with error message
  #
  def create
    sign_out(current_user) if current_user

    super do |resource|
      resource.auth_token = resource.generate_auth_token!(auth_source)

      yield resource if block_given?
    end
  end

  # DELETE /resource/sign_out
  # 로그아웃. 로그인이 되어 있지 않아도 에러를 발생하지는 않음
  # 토큰이용시 토큰을 삭제함
  #
  # ==== return
  # * +success+ - no_content
  # * +failure+ - no_content
  #
  def destroy
    user = current_user

    super do
      if user && request.headers["X-Auth-Token"].present?
        auth_token = user.auth_tokens.where(token: Digest::SHA512.hexdigest(request.headers["X-Auth-Token"])).first
        auth_token.destroy if auth_token
      end
      
      yield resource if block_given?
    end
  end

  # GET /resource
  # 로그인한 사용자 정보 가져오기
  # * +success+ - current_user json return
  # * +failure+ - unauthentication with error message
  #
  def show
    resource = warden.authenticate(:scope => resource_name)
    if resource
      render json: resource
    else
      render json: {
        error: {
          code: "UNAUTHENTICATION"
        }
      }, :status => :unauthorized
    end
  end
end
