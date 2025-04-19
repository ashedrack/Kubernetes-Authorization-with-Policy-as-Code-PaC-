package permissions

default allow = false

# Allow users to access their own accounts
allow_own_account if {
    input.subject.role == "customer"
    input.resource.type == "account"
    input.resource.owner_id == input.subject.id
}

# Allow parent accounts to access child accounts
allow_parent_access if {
    input.subject.relation == "parent"
    input.resource.type == "account"
    input.resource.child_id == input.subject.child_id
}

# Allow team members to access shared resources
allow_team_access if {
    input.subject.role == "team_member"
    input.resource.type == "shared"
    input.resource.team_id == input.subject.team_id
}

# Main allow rule that combines all access rules
allow if {
    allow_own_account
}

allow if {
    allow_parent_access
}

allow if {
    allow_team_access
}
