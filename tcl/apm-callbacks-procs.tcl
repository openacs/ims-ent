# packages/ims-ent/tcl/apm-callbacks-procs.tcl

ad_library {
    
    Now we'll deal with previous sc from authentication
    
    @author Rocael Hernandez (roc@viaro.net)
    @creation-date 2004-06-04
    @arch-tag: 324dfbee-ce4e-4a83-8122-5a01cf80049c
    @cvs-id $Id$
}

namespace eval auth {}

ad_proc -private ims_enterprise::package_upgrade {
} {
     this will upgrade existing related SC from acs-authentication
    
    @author Rocael Hernandez (roc@viaro.net)
    @creation-date 2004-06-04
    
    @return 
    
    @error 
} {

    db_transaction {
	ims_enterprise::unregister_impl
	ims_enterprise::register_impl
    }

}


ad_proc -private ims_enterprise::register_impl {} {
    Register this implementation
} {
    set spec {
        contract_name "auth_sync_process"
        owner "acs-authentication"
        name "IMS_Enterprise_v_1p1"
        pretty_name "IMS Enterprise 1.1"
        aliases {
            ProcessDocument ims_enterprise::parser::ProcessDocument
            GetAcknowledgementDocument auth::sync::process_doc::ims::GetAcknowledgementDocument
            GetElements auth::sync::process_doc::ims::GetElements
            GetParameters auth::sync::process_doc::ims::GetParameters
        }
    }

    return [acs_sc::impl::new_from_spec -spec $spec]

}

ad_proc -private ims_enterprise::unregister_impl {} {
    Unregister this implementation
} {
    acs_sc::impl::delete -contract_name "auth_sync_process" -impl_name "IMS_Enterprise_v_1p1"
}
