# packages/ims-ent/tcl/batch-procs.tcl

ad_library {
    
    Contains some of the same functions that sync-procs.tcl
    (acs-authentication), but with some modifications
    
    @author Rocael Hernandez (roc@viaro.net)
    @creation-date 2004-06-04
    @arch-tag: 69da0967-01a8-4020-8100-6c5d88857e67
    @cvs-id $Id$
}

namespace eval ims_enterprise {}
namespace eval ims_enterprise::sync {}
namespace eval ims_enterprise::sync::job {}

ad_proc -public ims_enterprise::sync::job::get_entry {
    {-entry_id:required}
    {-array:required}
} { 
    Get information about a log entry
} {
    upvar 1 $array row

    db_1row select_entry {
        select e.entry_id,
               e.job_id,
               e.entry_time,
               e.operation,
               j.authority_id,
               e.username,
               e.user_id,
	       e.community_key,
	       e.department_key,
	       e.subject_key,
	       e.class_key,
	       e.class_instance_key,
               e.success_p,
               e.message,
               e.element_messages
        from   auth_batch_job_entries e,
               auth_batch_jobs j
        where  e.entry_id = :entry_id
        and    j.job_id = e.job_id
    } -column_array row
}

ad_proc -public ims_enterprise::sync::job::create_entry {
    {-job_id:required}
    {-operation:required}
    {-username ""}
    {-user_id ""}
    {-community_key ""}
    {-department_key ""}
    {-subject_key ""}    
    {-class_key ""}    
    {-class_instance_key ""}    
    {-success:boolean}
    {-message ""}
    {-element_messages ""}
} {
    Record a batch job entry.

    @param job_id The ID of the batch job you're ending.
    
    @param operation One of 'insert', 'update', or 'delete'.

    @param username The username of the user being inserted/updated/deleted.
    
    @param community_key The community id related to the transacion.

    @param user_id The user_id of the local user account, if known.

    @param success Whether or not the operation went well.
    
    @param message Any error message to stick into the log.
    
    @return entry_id
} {
    set success_p_db [ad_decode $success_p 1 "t" "f"]

    set entry_id [db_nextval "auth_batch_job_entry_id_seq"]

    db_dml insert_entry {
            insert into auth_batch_job_entries
            (entry_id, job_id, operation, username, user_id, community_key, department_key, subject_key, class_key, class_instance_key, success_p, message, element_messages)
            values
            (:entry_id, :job_id, :operation, :username, :user_id, :community_key, :department_key, :subject_key, :class_key, :class_instance_key, :success_p_db, :message, :element_messages)
    } -clobs [list $element_messages]

    return $entry_id
}
