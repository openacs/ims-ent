# 

ad_library {
    
    specific library for Galileo University needs
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-06-10
    @arch-tag: 4331F72E-BB58-11D8-A758-000A95ABB5AA
    @cvs-id $Id$
}


namespace eval ims_enterprise::dotlrn {}

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
    return

    set user_id [db_string get_user_id {
	select user_id from carnets where carnet = :ims_id
    } -default "" ]

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
	update carnets set type = :roletype
	where carnet = :carnet
    }
}
