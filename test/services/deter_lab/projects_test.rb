require 'services/deter_lab/abstract_test'

class DeterLab::ProjectsTest < DeterLab::AbstractTest

  test "getting project profile description" do
    VCR.use_cassette "deterlab/projects/project-profile-description" do
      fields = DeterLab.get_project_profile_description

      assert_equal ProfileField.new("URL", "string", true, "READ_WRITE", "URL", nil, nil, "0", nil), fields["URL"]
      assert_equal ProfileField.new("funders", "string", true, "READ_WRITE", "Funders", nil, nil, "0", nil), fields["funders"]
    end
  end

  test "getting project profile" do
    VCR.use_cassette "deterlab/projects/project-profile" do
      login
      profile = DeterLab.get_project_profile(@username, "SPIdev")
      assert_equal "Project for developing DETER System Programming Interface code\n\nWe've reached the point where having a project for testing this code will be helpful.", profile['description'].value
    end
  end

  test "getting user projects" do
    VCR.use_cassette "deterlab/projects/view-projects" do
      login
      projects = DeterLab.view_projects(@username)

      assert_equal [
        Project.new("SPIdev", "faber", true,
          [ ProjectMember.new("bfdh", [ "CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER" ]),
            ProjectMember.new("spiuidev", [ "CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER" ]),
            ProjectMember.new("jsebes",   [ "CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER" ]),
            ProjectMember.new("faber",    [ "CREATE_EXPERIMENT", "CREATE_LIBRARY", "REMOVE_USER", "CREATE_CIRCLE", "ADD_USER" ])
          ])
      ], projects
    end
  end

  test "creating a project successfully" do
    VCR.use_cassette "deterlab/projects/create-project" do
      login
      assert DeterLab.create_project(@username, "unit-test-project-3", @username, { description: "Unit test project", URL: "http://sample.com/" })
      # open-ended attribute is gone from this test env, so commmented out for history
      # assert DeterLab.create_project(@username, "unit-test-project-3", @username, { description: "Unit test project", URL: "http://sample.com/", "test-open" => "test" })
    end
  end

  test "failing to create a project" do
    VCR.use_cassette "deterlab/projects/create-project-failure" do
      login
      assert_raises DeterLab::RequestError do
        DeterLab.create_project(@username, "unit-test-project-failure", @username, { description: "" })
      end
    end
  end

  test "deleting a project" do
    VCR.use_cassette "deterlab/projects/delete-project" do
      login
      assert DeterLab.create_project(@username, "unit-test-delete", @username, { "description" => "Project for unit test deletion" })
      assert DeterLab.remove_project(@username, "unit-test-delete")
    end
  end

  test "failed deleting of a project" do
    VCR.use_cassette "deterlab/projects/delete-project-failure" do
      login
      err = assert_raises DeterLab::RequestError do
        DeterLab.remove_project(@username, "missing")
      end

      assert_equal "Invalid projectid", err.message
    end
  end

  test "creating project anonymously" do
    VCR.use_cassette "deterlab/projects/create-project-anon" do
      user_id = DeterLab.create_user(user_profile)
      assert DeterLab.create_project(user_id, "unit-test-anon", user_id, { description: "descr" })
    end
  end

  def user_profile
    { name: "Mark Smith",
      email: "mark@smith.com",
      phone: "1234567891",
      title: "Mr",
      affiliation: "X Corp",
      affiliation_abbrev: "XC",
      URL: "http://xcorp.org",
      address1: "1 Main st.",
      address2: "",
      city: "Carrum",
      state: "Vic",
      zip: "3127",
      country: "Australia" }
  end

end
