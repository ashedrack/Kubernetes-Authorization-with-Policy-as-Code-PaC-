package permissions

test_user_can_access_own_account if {
    allow with input as {
        "subject": {"id": "user-1", "role": "customer"},
        "resource": {"type": "account", "owner_id": "user-1"}
    }
}

test_parent_can_access_child_account if {
    allow with input as {
        "subject": {"relation": "parent", "child_id": "child-1"},
        "resource": {"type": "account", "child_id": "child-1"}
    }
}

test_team_member_can_access_shared_resource if {
    allow with input as {
        "subject": {"role": "team_member", "team_id": "team-1"},
        "resource": {"type": "shared", "team_id": "team-1"}
    }
}

test_deny_unauthorized_access if {
    not allow with input as {
        "subject": {"id": "user-2", "role": "customer"},
        "resource": {"type": "account", "owner_id": "user-1"}
    }
}
