class Api::Authorize

  def initialize(headers = {})
    @headers = headers
  end

  def call
    page
  end

  private
    attr_reader :headers

    def page
      user = User.find_by(:uid => headers['User'])
      if user
        page = Page.find_by(page_id: decoded_auth_token[:page_id]) if decoded_auth_token
        if page && user.has_role?(:team, page)
          @page ||= page
        end
      else
        return { error: 'User doesn\'t exists!' , status: 404}
      end

      return @page || { error: 'Invalid token!', status: 401 }
    end

    def decoded_auth_token
      @decoded_auth_token ||= Api::ManageToken.decode(http_auth_header)
    end

    def http_auth_header
      if headers['Authorization'].present?
        return headers['Authorization'].split(' ').last
      end
      nil
    end
end
