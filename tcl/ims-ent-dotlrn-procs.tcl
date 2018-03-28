ad_library {
    
    new library, for handling the manipulation of .LRN stuff from the
    xml file feed
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-05
    @arch-tag: 656A1108-872F-11D8-B325-000A95ABB5AA
    @cvs-id $Id$
}


namespace eval ims_enterprise {}
namespace eval ims_enterprise::ims_dotlrn {}
namespace eval ims_enterprise::ims_dotlrn::groups {}
namespace eval ims_enterprise::ims_dotlrn::membership {}


ad_proc -private ims_enterprise::ims_dotlrn::recstatus {
    {-recstatus:required}
} {
     This should return if recstatus =
    1 = insert
    2 = update
    3 = delete
    4 = snapshot
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-01
    
    @param recstatus

    @return one of those string values
    
    @error 
} {
    
    switch $recstatus {
	1 {
	    set operation "insert"
	}
	2 { 
	    set operation "update"
	}
	3 {
	    set operation "delete"
	}
	default {
	    set operation "snapshot"
	}
    }

    return $operation
}


ad_proc -private ims_enterprise::ims_dotlrn::groups::department_check {
    dep_id
} {
     checks if a deparment in .LRN exists
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-01
    
    @param dep_id

    @return 1 if yes, 0 if not
    
    @error 
} {
    
    return [db_string get { *SQL* }]

}

ad_proc -private ims_enterprise::ims_dotlrn::groups::subject_check {
    sub_id
    dep_key
} {
     checks if a subject in .LRN exists
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-01
    
    @param dep_id

    @return 1 if yes, 0 if not
    
    @error 
} {
    set community_type "${dep_key}.${sub_id}"
    return [db_string get { *SQL* }]

}


ad_proc -private ims_enterprise::ims_dotlrn::groups::department {
    {-job_id:required}
    {-department_key:required}
    {-pretty_name:required}
    {-description ""}
    {-external_url ""}
    {-operation:required}
} {
     this creates a new department of .LRN from the XML data
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-05
    
    @param department_key

    @param operation

    @return if it was successful the operation or not, if not, why it fails
    
    @error 
} {

    db_transaction {

	set success_p 1
        array set result {
            message {}
            element_messages {}
        }
        

    
	set dep_exist_p [department_check $department_key]

	switch $operation {
	    snapshot {
		if ${dep_exist_p} {
		    set operation update
		} else {
		    set operation insert
		}
	    }		 
	    update {		
		if !${dep_exist_p} {
		    set success_p 0
		    set result(message) "department <group>: A department with this key '$department_key' does not exist"
		}
	    }
	    delete {		
		if !${dep_exist_p} {
		    set success_p 0
		    set result(message) "department <group>: A department with this key '$department_key' does not exist"
		} elseif {[db_string n_classes { *SQL* }] == 0} {
		    set success_p 0
		    set result(message) "department <group>: A department with this key '$department_key' has more classes associated "
		}
	    }
	    insert {
		if ${dep_exist_p} {
		    set success_p 0
		    set result(message) "department <group>: A department with this key '$department_key' already exist"
		}
	    }		 

	}

        if { $success_p } {
            with_catch errmsg {
		switch $operation {
		    insert {
			
			dotlrn_department::new \
			    -department_key $department_key \
			    -pretty_name $pretty_name \
			    -description $description \
			    -external_url $external_url

		    }
		    update {
			
			db_dml update_department {}
			db_dml update_community_type {}

		    }
		    delete {
			
			dotlrn_department::delete \
			    -department_key $department_key

		    }
		}
    
		set result(message) "department <group> $operation"
	    }  {
                # Get errorInfo and log it
                global errorInfo
                ns_log Error "department <group>: Error during batch syncrhonization job (department):\n$errorInfo"
                set success_p 0
                set result(message) "department <group>: $errorInfo"
            }
	}

        # Make a log entry
        set entry_id [ims_enterprise::sync::job::create_entry \
                          -job_id $job_id \
                          -operation $operation \
			  -department_key $department_key \
                          -success=$success_p \
                          -message $result(message) \
                          -element_messages $result(element_messages)]

    }

}




ad_proc -private ims_enterprise::ims_dotlrn::groups::subject {
    {-job_id:required}
    {-class_key:required}
    {-department_key:required}
    {-pretty_name:required}
    {-description ""}
    {-operation:required}
} {
    To create subjects on .LRN from XML IMS Enterprise
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-05
    
    @param department_key

    @param operation

    @return 
    
    @error 
} {

    db_transaction {

	set success_p 1
        array set result {
            message {}
            element_messages {}
        }

	if [empty_string_p $department_key] {
		set success_p 0
		set result(message) "subject <group>: A subject without department_key was attempted to be created."
	} else {	    

	    set sub_exist_p [subject_check $class_key $department_key]
	    set dep_exist_p [department_check $department_key]
	    
	    switch $operation {
		snapshot {
		    if { !${sub_exist_p} && ${dep_exist_p} } {
			set operation insert		    
		    } else {
			set operation update
		    }
		}
		update {
		    if { !${sub_exist_p} } {
			set success_p 0
			set result(message) "subject <group>: A subject with this class key '$class_key' does not exist"		    
		    }
		}
		insert {	   	    
		    if { !${dep_exist_p} } {
			set success_p 0
			set result(message) "subject <group>: A subject cannot be created since the department key '$department_key' does not exist"		    
		    } elseif { ${sub_exist_p} } {
			set success_p 0
			set result(message) "subject <group>: A subject with this class key '$class_key' already exist"		    
		    }
		}
		delete {
		    set success_p 0
		    set result(message) "subject <group>: Deleteting a subject is not supported"
		}
	    }
	}

        if { $success_p } {
            with_catch errmsg {
		switch $operation {
		    insert {	   
			
			dotlrn_class::new \
			    -class_key $class_key \
			    -department_key $department_key \
			    -pretty_name $pretty_name \
			    -description $description
			
		    }
		    update {
			
			db_dml update_community_type {}
			
		    }
		} ;#switch
		set result(message) "subject <group> $operation"
	    }  {
                # Get errorInfo and log it
                global errorInfo
                ns_log Error "subject <group>: Error during batch syncrhonization job (subject):\n$errorInfo"
                set success_p 0
                set result(message) "subject <group>: $errorInfo"
            }
	}

	# Make a log entry
	set entry_id [ims_enterprise::sync::job::create_entry \
			  -job_id $job_id \
			  -operation $operation \
			  -department_key $department_key \
			  -subject_key $class_key \
			  -success=$success_p \
			  -message $result(message) \
			  -element_messages $result(element_messages)]

    }
}
	    






ad_proc -private ims_enterprise::ims_dotlrn::get_community_id {
    class_instance_key
} {
    
    get the community_id on .LRN context
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-14
    
    @param class_instance_key

    @return community_id or empty string
    
    @error 
} {
    return [db_string get_comm_id { *SQL* } -default ""]
}




ad_proc -private ims_enterprise::ims_dotlrn::groups::class {
    {-job_id:required}
    {-class_instance_key:required}
    {-class_key:required}
    {-term_id:required}
    {-pretty_name:required}
    {-description ""}
    {-join_policy}
    {-operation:required}
} {
    To create classes on .LRN from XML IMS Enterprise
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-05
    
    @param department_key

    @param operation

    @return 
    
    @error 
} {

    db_transaction {

	set success_p 1
        array set result {
            message {}
            element_messages {}
        }

	if [empty_string_p $class_key] {
		set success_p 0
		set result(message) "class <group>: A class  with this class key '$class_instance_key' was not found on the system"		    
	} else {	    

	    # search on the relationships if there is one with a department,
	    # go with the first one found, if none, we'll have error on
	    # inserts

	    set community_id [ims_enterprise::ims_dotlrn::get_community_id $class_instance_key]

	    switch $operation {
		snapshot {
		    if [empty_string_p ${community_id}] {
			set operation insert
		    } else {
			set operation update
		    }
		}
		insert {
		    if ![empty_string_p ${community_id}] {
			set success_p 0
			set result(message) "class <group>: A class with this class instance key '$class_instance_key' already exist"		    
		    }
		}
		update {
		    if [empty_string_p ${community_id}] {
			set success_p 0
			set result(message) "class <group>: A class instance with this class instance key '$class_instance_key' does not exist"		    
		    }
		}
		delete {
		    set success_p 0
		    set result(message) "class <group>: Deleteting a class instance is not supported"
		}
	    }
	}

        if { $success_p } {
            with_catch errmsg {
		switch $operation {
		    insert {	   
	    
			set class_instance_id [dotlrn_class::new_instance \
						   -class_key $class_key \
						   -term_id $term_id \
						   -pretty_name $pretty_name \
						   -description $description \
						   -join_policy $join_policy \
						  ]		
			db_dml map_class { *SQL* }

		    }	     
		    update {

			dotlrn_community::set_community_name \
			    -community_id $community_id \
			    -pretty_name $pretty_name
			
			dotlrn_community::set_community_description \
			    -community_id $community_id \
			    -description $description
		    }
		    delete {

			# this is dangerous, since for one error in XML data we
			# might archive an active class, so just lets do nothing
			# by now, this part won't execute in any case (roc)

			# what we can really do is to *archive* it

			set subcomm_id [dotlrn_community::archive \
					    -community_id $community_id]

		    }				
		} ;#switch
		set result(message) "class <group> $operation"
	    }  {
		# Get errorInfo and log it
		global errorInfo
		ns_log Error "class <group>: Error during batch syncrhonization job (class):\n$errorInfo"
		set success_p 0
		set result(message) "class <group>: $errorInfo"
	    }
	}

	# Make a log entry
	set entry_id [ims_enterprise::sync::job::create_entry \
			  -job_id $job_id \
			  -operation $operation \
			  -class_key $class_key \
			  -class_instance_key $class_instance_key \
			  -success=$success_p \
			  -message $result(message) \
			  -element_messages $result(element_messages)]
    }
}


ad_proc -private ims_enterprise::ims_dotlrn::groups::guess_term {
    start_date
    end_date
} {
    
    Here we'll try to see if we found a proper TERM for this specific
    dates that we receive.
    We need better implementation for this one.
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-06
    
    @param start_date

    @param end_date

    @return 
    
    @error 
} {

    set term_id [db_string get_best_term { *SQL* } -default ""]

    #if no term create one
    if [empty_string_p $term_id] {

	set term_year [dotlrn_term::start_end_dates_to_term_year \
		       -start_date [split $start_date {-}] \
			-end_date [split $end_date {-}]
		      ]

	dotlrn_term::new \
	    -term_name "$start_date$end_date" \
	    -term_year $term_year \
	    -start_date $start_date \
	    -end_date $end_date

	set term_id [db_string get_best_term { *SQL* } -default ""]
    }

    return $term_id
    
}


ad_proc -private ims_enterprise::ims_dotlrn::membership::rel_type {
    roletype
} {
    
    will return the proper rel_type for a give role that we got from
    IMS document
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-14
    
    @param roletype

    @return 
    
    @error 
} {
    
    # this should be customized using params or some sort of mapping
    # (roc), what about numbers like 01, 02 ...??
    set roletype [string trimleft $roletype 0]

    switch $roletype {
	2 { return dotlrn_instructor_rel }
	7 -
	5 { return dotlrn_cadmin_rel }
	3 { return dotlrn_ca_rel }
	6 -
	8 { return dotlrn_ta_rel }
	4 -
	1 { return dotlrn_student_rel }
    }

}


ad_proc -private ims_enterprise::ims_dotlrn::membership::membership {
    {-job_id:required}
    {-class_instance_key:required}
    {-community_id:required}
    {-id:required}
    {-authority_id:required}
    {-roletype:required}
    {-operation:required}
    {user_id {}}
} {
    
    To handle the membership between users & groups from XML IMS Enterprise
    
    @author Rocael Hernandez (roc@viaro.net)
    @creation-date 2004-06-03
    
    @param job_id

    @param class_instance_key

    @param community_id

    @param id ID that's coming at IMS XML doc, which identify a
     given user in our system (isn't the user_id, but we'll use it for getting it)

    @param authority_id

    @param roletype

    @param operation

    @param user_id if we get the user_id, will from an snapshot user
     delete process

    @return 
    
    @error 
} {

    db_transaction {

	set success_p 1
        array set result {
            message {}
            element_messages {}
        }

	# if the community_id doesn't exist, then its an error
	if [empty_string_p $community_id] {
	    set success_p 0
	    set result(message) "<membership>: The community_id $community_id doesn't exist"		    
	} else {

	    if [empty_string_p $user_id] {

		# now lets call the proc defined as param, it must
		# return the user_id	    

		set proc_name [parameter::get_from_package_key -package_key ims-ent -parameter UserIdReturnProc]
		# execute the proc and get the user_id
		
		set proc_list [list [lindex ${proc_name} 0] [lindex ${proc_name} 1] $id -authority_id $authority_id]
		set user_id [eval $proc_list]

	    }

	    if { [empty_string_p $user_id] } {
		# Updating/deleting a user that doesn't exist
		set success_p 0
		set result(message) "A user with id '$id' does not exist"
	    } else {
		acs_user::get -user_id $user_id -array existing_user_info
		if { [string equal $existing_user_info(member_state) "banned"] } {
		    # Updating/deleting a user that's already deleted
		    set success_p 0
		    set result(message) "The user with id '$id' has been deleted (banned)"
		} elseif ![dotlrn::user_p -user_id $user_id] {
		    # This is not a dotlrn user
		    set success_p 0
		    set result(message) "<membership>: The user with id '$id' isn't a dotlrn user"
                }	
	    }
	}
	if { $success_p } {
            with_catch errmsg {

		set member_p [dotlrn_community::member_p $community_id $user_id]

		# this will work for recstatus=delete, but we need to
		# do it for any update as well.
		if {$member_p} {
		    dotlrn_community::remove_user $community_id $user_id
		}

		if {$operation != "delete" } { 
	    
		    # this will work for insert, update and snapshot
		    # as well, since there are not specific procs for update a
		    # dotlrn rel, just add/delete
		    set rel_type [ims_enterprise::ims_dotlrn::membership::rel_type $roletype]
		
		    dotlrn_community::add_user -rel_type $rel_type $community_id $user_id

		    # lets update the given ID type for this user_id
#		    ims_enterprise::dotlrn::set_carnet_type -carnet $id -roletype $roletype
		}
		set result(message) "<membership>"
	    }  {
		# Get errorInfo and log it
		global errorInfo
		ns_log Error "<membership>: Error during batch syncrhonization job (membership):\n$errorInfo"
		set success_p 0
		set result(message) "<membership>: $errorInfo"
	    }
	}

	# Make a log entry
	set entry_id [ims_enterprise::sync::job::create_entry \
			  -job_id $job_id \
			  -operation $operation \
			  -username $id \
			  -user_id $user_id \
			  -community_key $community_id \
			  -class_instance_key $class_instance_key \
			  -success=$success_p \
			  -message $result(message) \
			  -element_messages $result(element_messages)]

    }    

    return $user_id
}
