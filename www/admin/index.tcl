ad_page_contract {
    Index page for External Authentication listing
    available authorities.

    @author Peter Marklund
    @creation-date 2003-09-08
}

set page_title "Authentication"
set context [list $page_title]

list::create \
    -name "authorities" \
    -multirow "authorities" \
    -key authority_id \
    -elements {
        pretty_name {
            label "Name"
            link_url_eval {[export_vars -base authority { authority_id }]}
        }
        enabled {
            label "Enabled"
            html { align center }
            display_template {
                <if @authorities.enabled_p@ true>
                  <a href="@authorities.enabled_p_url@" title="Disable this authority"><img src="/shared/images/checkboxchecked" height="13" width="13" border="0" style="background-color: white;"></a>
                </if>
                <else>
                  <a href="@authorities.enabled_p_url@" title="Enable this authority"><img src="/shared/images/checkbox" height="13" width="13" border="0" style="background-color: white;"></a>
                </else>
            }
        }
        delete {
            label ""
            display_template {
                <if @authorities.short_name@ ne local>
                  <a href="@authorities.delete_url@"
                     title="Delete this authority"
                     onclick="return confirm('Are you sure you want to delete authority @authorities.pretty_name@?');">
                    <img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0">
                  </a>
                </if>
            }
            sub_class narrow
        }        
    }

# The authority currently selected for registering users
set register_authority_id [auth::get_register_authority]

db_multirow -extend { 
    enabled_p_url 
    sort_order_url_up 
    sort_order_url_down 
    delete_url
    registration_url
    registration_status
} authorities authorities_select {
    select authority_id,
           short_name,
           pretty_name,
           enabled_p,
           sort_order,
           (select max(sort_order) from auth_authorities) as lowest_sort_order,
           (select min(sort_order) from auth_authorities) as highest_sort_order,
           (select impl_pretty_name from acs_sc_impls where impl_id = auth_impl_id) as auth_impl,
           (select impl_pretty_name from acs_sc_impls where impl_id = pwd_impl_id) as pwd_impl,
           (select impl_pretty_name from acs_sc_impls where impl_id = register_impl_id) as reg_impl
    from   auth_authorities
    where process_doc_impl_id = 
    (select asi.impl_id from acs_sc_impls asi
     where asi.impl_contract_name = 'auth_sync_process')
    order  by sort_order
} {
    set toggle_enabled_p [ad_decode $enabled_p "t" "f" "t"]
    set enabled_p_url "authority-set-enabled-p?[export_vars { authority_id {enabled_p $toggle_enabled_p} }]"
    set delete_url [export_vars -base authority-delete { authority_id }]
    set sort_order_url_up "authority-set-sort-order?[export_vars { authority_id {direction up} }]"
    set sort_order_url_down "authority-set-sort-order?[export_vars { authority_id {direction down} }]"

    if { [string equal $authority_id $register_authority_id] } {
        # The authority is selected as register authority
        set registration_status "selected"
    } elseif { ![empty_string_p $reg_impl] } {
        # The authority can be selected as register authority
        set registration_status "can_select"
        set registration_url [export_vars -base authority-registration-select { authority_id }]
    } else {
        # This authority has no account creation driver
        set registration_status "cannot_select"
    }    
}

set auth_package_id [apm_package_id_from_key "acs-authentication"]
set parameter_url [export_vars -base /shared/parameters { { package_id $auth_package_id } { return_url [ad_return_url] } }]
