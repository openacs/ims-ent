# 

ad_library {
    
    specific library for Galileo University needs
    Might help as a reference for other users of this pkg
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-06-10
    @arch-tag: 4331F72E-BB58-11D8-A758-000A95ABB5AA
    @cvs-id $Id$
}


namespace eval ims_enterprise::dotlrn {}


#----------------------ug-local-automatic-------------


ad_proc -private ims_enterprise::dotlrn::register {
    {-ims_id:required}
    {-authority_id:required}
} {

    set impl_id [auth::authority::get_element -authority_id $authority_id -element "auth_impl_id"]

    if { [empty_string_p $impl_id] } {
        # No implementation of authentication
        set authority_pretty_name [auth::authority::get_element -authority_id $authority_id -element "pretty_name"]
        error "The authority '$authority_pretty_name' doesn't support authentication"
    }

    set parameters [auth::driver::get_parameter_values \
                        -authority_id $authority_id \
                        -impl_id $impl_id]

    set userPassword [auth::ldap::get_user -username $ims_id -parameters $parameters -element "userPassword"]
    if { [llength $search_result] != 1 } {
	return
    }
    lappend parameters InfoAttributeMap "first_names=givenName;last_name=sn;email=mail;field_name=userClass"
    array set info_result [auth::local_ldap::user_info::GetUserInfo $ims_id $parameters]

    array set user_info $info_result(user_info)
    set user_id [ad_user_new  $user_info(email) \
		     $user_info(first_names)  $user_info(last_name) \
		     $password  {} {}  {}  1  "approved"  {}  $username  $authority_id  $username]

    # Also, register the carnet (username) only for this very first
    # time (roc) !!!!!!!

    db_dml register_id { insert into ug_user_id_member_field_map (user_id, field_name, field_value) values (:user_id, :user_info(field_name), :username) }

    db_dml update_passwd { update users set password = :userPassword, salt = '' where user_id = :user_id }

}

#--------------------------------------


ad_proc -private ims_enterprise::dotlrn::get_user_id {
    {-ims_id:required}
    {-authority_id:required}
} {
     get the user_id, that's related to the student_id map table that
     is tied to a give user_id
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-06-10
    
    @param ims_id

    @param authority_id

    @return 
    
    @error 
} {
#    return

    set user_id [db_string get_user_id {
	select user_id from ug_user_id_member_field_map where field_value = :ims_id
    } -default "" ]

    if [empty_string_p $user_id] {
	# try to authenticate this user (search on ldap & register locally)

	ims_enterprise::dotlrn::register -ims_id $ims_id -authority_id $authority_id

#	auth::authentication::Authenticate -authority_id $authority_id -username $ims_id -password $ims_id

	set user_id [db_string get_user_id {
	    select user_id from ug_user_id_member_field_map where field_value = :ims_id
	} -default "" ]
    }

    return $user_id
}

ad_proc -private ims_enterprise::dotlrn::set_carnet_type {
    {-carnet:required}
    {-roletype:required}
} {
     This proc will be called among membership proc to update 
     the info about the type it is a given carnet.
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-06-10
    
    @param carnet

    @param roletype

    @return 
    
    @error 
} {

    return

    db_dml set_carnet_type {
	update user_id_member_field_map set field_name = :roletype
	where carnet = :carnet
    }
}

