# packages/ims-ent/www/index.tcl

ad_page_contract {
    
    
    
    @author Rocael Hernandez (roc@viaro.net)
    @creation-date 2004-05-19
    @arch-tag: f4e6662a-79fa-4343-9afe-711ac085fc03
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]