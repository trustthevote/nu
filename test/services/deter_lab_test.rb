require 'test_helper'

class DeterLabTest < ActiveSupport::TestCase

  setup do
    @username = TestsConfig['username']
    @password = TestsConfig['password']
  end

  test "version returns version" do
    VCR.use_cassette "deterlab-version" do
      assert_equal "0.2/0.0", DeterLab.version
    end
  end

  test "it should return false for bad login" do
    VCR.use_cassette "deterlab-login-bad" do
      assert !DeterLab.valid_credentials?("unk", "badpass")
    end
  end

  test "it should return true for good login" do
    VCR.use_cassette "deterlab-confidential-login-good" do
      login
      assert_not_nil SslKeyStorage.get(@username)
    end
  end

  # -------------------------------------------------------------------------------------

  test "getting profile description" do
    VCR.use_cassette "deterlab-profile-description" do
      fields = DeterLab.get_profile_description
      assert_equal fields["URL"], ProfileField.new("URL", "string", true, "READ_WRITE", "URL", nil, nil, "0", nil)
      assert_equal fields["phone"], ProfileField.new("phone", "string", false, "READ_WRITE", "Phone", "[0-9-\\s\\.\\(\\)\\+]+", "Numbers, whitespace, parens, and dots or dashes", "15", nil)
    end
  end

  test "getting user profile" do
    VCR.use_cassette "deterlab-confidential-user-profile" do
      login
      profile = DeterLab.get_user_profile(@username)
      assert_equal profile['zip'], '06405'
    end
  end

  # -------------------------------------------------------------------------------------

  test "getting user projects" do
    VCR.use_cassette "deterlab-confidential-user-projects" do
      login
      projects = DeterLab.get_user_projects(@username)

      assert_equal projects,
        [ Project.new("admin", "deterboss", true,
            [ ProjectMember.new("deterboss", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"]),
              ProjectMember.new("bfdh", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"]),
              ProjectMember.new("faber", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"])
            ]),
          Project.new("SPIdev", "faber", true,
            [ ProjectMember.new("bfdh", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"]),
              ProjectMember.new("jsebes", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"]),
              ProjectMember.new("faber", ["CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER"])
            ])
        ]
    end
  end

  # -------------------------------------------------------------------------------------

  test "getting experiments" do
    VCR.use_cassette "deterlab-confidential-user-experiments" do
      login
      list = DeterLab.get_user_experiments(@username)
      assert list
    end
  end

  # -------------------------------------------------------------------------------------


  private

  def login
    skip("Valid test user is missing from tests-config.yml") if @username.blank? or @password.blank?
    assert DeterLab.valid_credentials?(@username, @password)
  end
end
