module SpecAuthHelper
  def set_omniauth(opts = {})
    default = {:provider => :github,
               :uuid     => "1234",
               :github => {
                              :email => "foobar@example.com",
                              :gender => "Male",
                              :first_name => "foo",
                              :last_name => "bar"
                            }
              }

    credentials = default.merge(opts)
    provider = credentials[:provider]
    user_hash = credentials[provider]

    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[provider] = {
      'uid' => credentials[:uuid],
      "extra" => {
      "user_hash" => {
        "email" => user_hash[:email],
        "first_name" => user_hash[:first_name],
        "last_name" => user_hash[:last_name],
        "gender" => user_hash[:gender]
        }
      }
    }
    OmniAuth.config.add_mock(:github, OmniAuth.config.mock_auth[:github])
  end

  def set_invalid_omniauth(opts = {})

    credentials = { :provider => :github,
                    :invalid  => :invalid_crendentials
                   }.merge(opts)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[credentials[:provider]] = credentials[:invalid]

  end
end