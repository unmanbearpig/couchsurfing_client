module CouchSurfingClient
  class SignInPage
    def initialize page
      @page = page
    end

    def signed_in?
      !@page.links.select { |link| link.text == 'Log out' }.empty?
    end

    def sign_in username, password
      form = sign_in_form

      unless form
        if signed_in?
          fail SignInError, 'Trying to sign in when already signed in'
        else
          fail SignInError, 'Could not find sign in form on the main page'
        end
      end

      form.username = username
      form.password = password

      begin
        result = form.submit
      rescue Mechanize::ResponseCodeError => e
        raise SignInError, 'Sign in failed', e
      end

      unless result.code == '200'
        fail SignInError, "Could not log in, response error #{result.code}"
      end
    end

    private

    def sign_in_form
      @page.form_with action: '/n/auth'
    end
  end
end
