module DeterLab
  module Projects

    # Returns a project profile description
    def get_project_profile_description
      get_profile_description("Projects")
    end

    def create_project_attribute(uid, name, type, optional, access, description, ordering_hint, format = "", format_description = "", length_hint = 0, default = "")
      cl = client("Projects", uid)
      response = cl.call(:create_project_attribute, message: {
        name:               name,
        type:               type,
        optional:           optional,
        access:             access,
        description:        description,
        format:             format,
        formatdescription:  format_description,
        order:              ordering_hint,
        length:             length_hint,
        def:                default
      })

      return response.to_hash[:create_project_attribute_response][:return]
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Returns the list of user projects
    def view_projects(uid)
      cl = client("Projects", uid)
      response = cl.call(:view_projects, message: { uid: uid })

      return [response.to_hash[:view_projects_response][:return] || []].flatten.map do |p|
        members = [ p[:members] ].flatten.map do |m|
          ProjectMember.new(m[:uid], m[:permissions])
        end

        Project.new(p[:project_id], p[:owner], p[:approved], members)
      end
    rescue Savon::SOAPFault => e
      process_error e
    end

    # returns the project profile
    def get_project_profile(uid, pid)
      cl = client("Projects", uid)
      response = cl.call(:get_project_profile, message: { projectid: pid })

      fields = [ response.to_hash[:get_project_profile_response][:return][:attributes] ].flatten.map do |f|
        ProfileField.new(f[:name], f[:data_type], f[:optional], f[:access], f[:description], f[:format], f[:format_description], f[:length_hint], f[:value])
      end

      return ProfileFields.new(fields)
    rescue Savon::SOAPFault => e
      process_error e
    end

    # changes project profile
    def change_project_profile(uid, pid, changes)
      cl = client("Projects", uid)
      changes = changes.inject([]) do |m, c|
        m << { name: c[0], value: c[1] }
        m
      end
      response = cl.call(:change_project_profile, message: { projectid: pid, changes: changes })

      res = [ response.to_hash[:change_project_profile_response][:return] || [] ].flatten
      return res.inject({}) do |m, r|
        m[r[:name]] = { success: r[:success], reason: r[:reason] }
        m
      end
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Creates a project with the given profile for approval.
    # Returns #true if created, or #false if not.
    def create_project(uid, name, owner, project_profile)
      cl = client("Projects", uid)
      response = cl.call(:create_project, message: {
        projectid: name,
        owner: owner,
        profile: project_profile.map { |f, v| { name: f, value: v.to_s } }
      })

      raise Error unless response.success?

      return response.to_hash[:create_project_response][:return]
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Creates the request to join the project.
    # Returns TRUE if the request was sent.
    def join_project(uid, project_id, url_prefix = nil)
      # alg self-note: url_prefix is for prepending to the challenge id in notificaiton and is visible only to
      # those approving the membership. Ignoring for now.
      cl = client("Projects", uid)
      response = cl.call(:join_project, message: {
        uid: uid,
        projectid: project_id,
        urlPrefix: url_prefix
      })

      res = response.to_hash[:join_project_response][:return]
      if res
        ProjectJoins.add_project(uid, project_id)
      end

      return res
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Approves the project
    def approve_project(admin_uid, project_id)
      cl = client("Projects", admin_uid)
      response = cl.call(:approve_project, message: {
        projectid: project_id,
        approved: true
      })
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Adds users to the project with confirmation
    def add_users(admin_uid, project_id, uids, perms = ProjectMember::DEFAULT_NEW_USER_PERMS)
      perms ||= []
      cl = client("Projects", admin_uid)
      response = cl.call(:add_users, message: {
        projectid: project_id,
        uids: uids,
        perms: perms
      })

      return [ response.to_hash[:add_users_response][:return] || [] ].flatten
    rescue Savon::SOAPFault => e
      process_error e
    end

    # Adds users to the project without confirmation
    def add_users_no_confirm(admin_uid, project_id, uids, perms = ProjectMember::DEFAULT_NEW_USER_PERMS)
      perms ||= []
      cl = client("Projects", admin_uid)
      response = cl.call(:add_users_no_confirm, message: {
        projectid: project_id,
        uids: uids,
        perms: perms
      })

      return response.to_hash[:add_users_no_confirm_response][:return]
    rescue Savon::SOAPFault => e
      process_error e
    end

    # removes users from the project
    def remove_users(admin_uid, project_id, uids)
      cl = client("Projects", admin_uid)
      response = cl.call(:remove_users, message: {
        projectid: project_id,
        uids: uids
      })

      return [ response.to_hash[:remove_users_response][:return] || [] ].flatten
    end

    # Deletes the project
    def remove_project(uid, project_id)
      cl = client("Projects", uid)
      response = cl.call(:remove_project, message: {
        projectid: project_id
      })

      return response.to_hash[:remove_project_response][:return]
    rescue Savon::SOAPFault => e
      process_error e
    end

  end
end
