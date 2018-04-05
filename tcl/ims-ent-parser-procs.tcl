ad_library {
    API for parsing and inserting the respective datamodel the data that has been obtained from the parsing of a IMS Enterprise v. 1.1 DTD
    
    @creation-date 2004-03-29
    @author Rocael Hernandez (roc@viaro.net)
    @cvs-id $Id$
}

namespace eval ims_enterprise {}
namespace eval ims_enterprise::parser {}

ad_proc -public ims_enterprise::parser::group_to_dotlrn {
    {-job_id:required}
    {-document:required}
} {
     For parsing the <group> tag of the IMS Enterprise v.1.1
     specification and calling the approiate procs
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-01
    
    @param document

    @return 
    
    @error 
} {
    

    set tree [xml_parse -persist $document]

    set root_node [xml_doc_get_first_node $tree]

    # Loop over <group> records
    # we'll process <typevalue level=> as:
    # 1. Departments
    # 2. Subjects
    # 3. Class instances
    # these are the defaults, but can be customized as parameters

    set lookup_levels [list [parameter::get_from_package_key -package_key ims-ent -parameter department] \
			   [parameter::get_from_package_key -package_key ims-ent  -parameter subject] \
			   [parameter::get_from_package_key -package_key ims-ent  -parameter class]]


    foreach lookup_level $lookup_levels {
	set xpath [format {/enterprise/group[grouptype/typevalue[@level=%i]]} $lookup_level]

	foreach group_node [xml_node_get_children_by_select $root_node $xpath] {

	    set recstatus [xml_node_get_attribute $group_node "recstatus"]

	    # <sourcedid>
	    set sourcedidtype [xml_get_child_node_attribute_by_path $group_node {sourcedid} "sourcedidtype"]
	    set id [xml_get_child_node_content_by_path $group_node { { sourcedid id } }]
	    set source [xml_get_child_node_content_by_path $group_node { { sourcedid source } }]

	    # 3.5 <description>

	    # we'll use just short rigth now, shall not be noll
	    set short [xml_get_child_node_content_by_path $group_node { { description short } }]
	    # temporal format
	    set short [string range $short 0 50]
	    # this migth be complementary info that might have a place to be in .LRN
	    set long [xml_get_child_node_content_by_path $group_node { { description long } }]
	    set full [xml_get_child_node_content_by_path $group_node { { description full } }]

	    # 3.7 <timeframe>

	    # this should help us on mapping a group to a term  (roc)
	    set begin_date [xml_get_child_node_content_by_path $group_node { { timeframe begin } }]
	    set begin_restrict [xml_get_child_node_attribute_by_path $group_node { timeframe begin } "restrict"]
	    set end_date [xml_get_child_node_content_by_path $group_node { { timeframe end } }]
	    set end_restrict [xml_get_child_node_attribute_by_path $group_node { timeframe end } "restrict"]
	    set adminperiod [xml_get_child_node_content_by_path $group_node { { timeframe adminperiod } }]


	    # 3.8 <enrollcontrol>

	    # control for enroll policies
	    set enrollaccept [xml_get_child_node_content_by_path $group_node { { enrollcontrol enrollaccept } }]
	    set enrollallowed [xml_get_child_node_content_by_path $group_node { { enrollcontrol enrollallowed } }]
	    
	    # 3.10 <url>

	    set url [xml_get_child_node_content_by_path $group_node { { url } }]


	    # 3.11 <relationship>

	    # we'll use it to know what which is the *possible* parent or children(s)
	    # for subjects we need: the 3.11.2 <sourceid> where the 3.11.1
	    # <relation> is 1 = Parent to determine the deparment_key 
	    # we really don't need to parse this, since all the mapping is
	    # done through <membership> tag (not any more!, we'll use this
	    # for mapping groups within them)

	    # department has no Parent so far, so we won't look for that now
	    if {$lookup_level != [parameter::get_from_package_key -package_key ims-ent  -parameter department]} {

		set relationships [list]
	    
		foreach relationship_node [xml_node_get_children_by_name $group_node "relationship"] {
		    set relation [xml_node_get_attribute $relationship_node "relation"]
		    set label [xml_get_child_node_content_by_path $relationship_node { { label } }]

		    # we'll get the sourcedid, but we don't expect right here
		    # to create it, rather, we expect that this key is already
		    # in the ims_ent_sourcedids table (by now at least) (roc)
		    set sourcedid [xml_get_child_node_content_by_path $relationship_node { { sourcedid id } }]

		    lappend relationships [list $relation $label $sourcedid]

		}

		# now look for parents if they are not provided 

		set parent_key ""
		foreach relation $relationships {
		    # 1 = Parent 
		    if {[lindex $relation 0] == 1} {
			set parent_key [lindex $relation 2]
			break
		    }
		}

		if [empty_string_p $parent_key] {
		    # we haven't found yet the parent, lets try to find it
		    # in the above level 
		
		    if {[parameter::get_from_package_key -package_key ims-ent  -parameter subject] == $lookup_level} {
			set parent_grouptype department
		    } else {
			set parent_grouptype subject
		    }

		    set xpath_up [format {/enterprise/group[grouptype/typevalue[@level=%i] and relationship/sourcedid[id='%s']]} \
				      [parameter::get_from_package_key -package_key ims-ent  -parameter $parent_grouptype] $id]
		    # do we need here a catch? to avoid parsing errors if
		    # its not found
		    set parent_node [xml_node_get_children_by_select $root_node $xpath_up]
		    if ![empty_string_p $parent_node] {
			set parent_key [xml_get_child_node_content_by_path $parent_node {{ sourcedid id } }]
		    }

		}

		set parent_key [string trim $parent_key]
		
	    }; #lookup_level



	    # now we call the actual proc that will create the specific stuff
	
	    set operation [ims_enterprise::ims_dotlrn::recstatus -recstatus $recstatus]

	    set id [string trim $id]

	    switch $lookup_level {
		1 {
		    # this range should not be here!
		    set long [string range $long 0 90]
		    ims_enterprise::ims_dotlrn::groups::department \
			-job_id $job_id \
			-department_key $id \
			-pretty_name $long \
			-description $full \
			-external_url $url \
			-operation $operation
		}
		2 {
		    ims_enterprise::ims_dotlrn::groups::subject \
			-job_id $job_id \
			-class_key $id \
			-department_key $parent_key \
			-pretty_name $short \
			-description $full \
			-operation $operation
		}
		3 {
		    
		set term_id [ims_enterprise::ims_dotlrn::groups::guess_term $begin_date $end_date]

		    # right now we assume that the <id> of a <group>
		    # is unique, so, now we need to determine the
		    # exact id for a this subject that this class
		    # belongs to, and in .LRN, automatically the
		    # subject key is generated as:
		    # department_key.class_key we might change the
		    # actual behaivor of .LRN to adapt more smoothly
		    # to the IMS Enterprise (roc)

		    # so lets get the proper key based on the original
		    # key that we got from the IMS DTD

		    set full_key [db_string class_key { *SQL* } -default ""]

		    ims_enterprise::ims_dotlrn::groups::class \
			-job_id $job_id \
			-class_instance_key $id \
			-class_key $full_key \
			-term_id $term_id \
			-pretty_name $long \
			-description $full \
			-join_policy $enrollaccept \
			-operation $operation
		}
	    }




	} ;# end foreach

    }; # foreach level

}

ad_proc -private ims_enterprise::parser::membership_to_dotlrn {
    {-job_id:required}
    {-authority_id:required}
    {-document:required}
} {
     
     For parsing the <membership> tag of the IMS Enterprise v.1.1
     specification and calling the approiate procs
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-04-14
    
    @param document

    @return 
    
    @error 
} {

    set tree [xml_parse -persist $document]

    set root_node [xml_doc_get_first_node $tree]

    foreach mem_node [xml_node_get_children_by_name $root_node "membership"] {

	# <sourcedid>
	set sourcedidtype [xml_get_child_node_attribute_by_path $mem_node {sourcedid} "sourcedidtype"]
	set id [xml_get_child_node_content_by_path $mem_node { { sourcedid id } }]
	set source [xml_get_child_node_content_by_path $mem_node { { sourcedid source } }]

	set community_id [ims_enterprise::ims_dotlrn::get_community_id $id]
	set class_instance_key $id

	set group_source $source

	set member_list [list]

	foreach member_node [xml_node_get_children_by_name $mem_node "member"] {

	    set sourcedidtype [xml_get_child_node_attribute_by_path $member_node {sourcedid} "sourcedidtype"]
	    set id [xml_get_child_node_content_by_path $member_node { { sourcedid id } }]
	    set source [xml_get_child_node_content_by_path $member_node { { sourcedid source } }]

	    # .LRN right now only allows you to assing one specific
	    # role for a given relation between a user and a class so
	    # we won't parse several times the <role> tag, instead
	    # will go with the first value that we get from it by now
	    # (roc)
	    set recstatus [xml_get_child_node_attribute_by_path $member_node {role} "recstatus"]
	    set roletype [xml_get_child_node_attribute_by_path $member_node {role} "roletype"]

	    set operation [ims_enterprise::ims_dotlrn::recstatus -recstatus $recstatus]

	    set user_id [ims_enterprise::ims_dotlrn::membership::membership \
			     -job_id $job_id \
			     -class_instance_key $class_instance_key \
			     -community_id $community_id \
			     -id $id \
			     -authority_id $authority_id \
			     -roletype $roletype \
			     -operation $operation]

	    if ![empty_string_p $user_id] {
		lappend member_list $user_id
	    }

	}

	if {$operation == "snapshot"} {
	    set member_list [join $member_list ", "]
	    set non_users_list [db_list get_non_sent_users { *SQL* }]
	    foreach id $non_users_list {
		ims_enterprise::ims_dotlrn::membership::membership \
		    -job_id $job_id \
		    -class_instance_key $class_instance_key \
		    -community_id $community_id \
		    -id $id \
		    -authority_id $authority_id \
		    -roletype $roletype \
		    -operation delete $id
	    }
	}

    }
}


ad_proc -private ims_enterprise::parser::ProcessDocument {
    job_id
    document
    parameters
} {
    Process IMS Enterprise 1.1 document.
} {

    # be sure that we'll create new users as .LRN users
    parameter::set_from_package_key -package_key acs-authentication -parameter SyncAddUsersToDotLrnP -value 1

    set tree [xml_parse -persist $document]

    set root_node [xml_doc_get_first_node $tree]

    if { ![string equal [xml_node_get_name $root_node] "enterprise"] } {
        error "Root node was not <enterprise>"
    }

    # Loop over <person> records
    foreach person_node [xml_node_get_children_by_name $root_node "person"] {
        switch [xml_node_get_attribute $person_node "recstatus"] {
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

        # Initialize this record
        array unset user_info

        set username [xml_get_child_node_content_by_path $person_node { { userid } { sourcedid id } }]

        set user_info(email) [xml_get_child_node_content_by_path $person_node { { email } }]
        set user_info(url) [xml_get_child_node_content_by_path $person_node { { url } }]

        # We need a little more logic to deal with first_names/last_name, since they may not be split up in the XML
        set user_info(first_names) [xml_get_child_node_content_by_path $person_node { { name n given } }]
        set user_info(last_name) [xml_get_child_node_content_by_path $person_node { { name n family } }]

        if { [empty_string_p $user_info(first_names)] || [empty_string_p $user_info(last_name)] } {
            set formatted_name [xml_get_child_node_content_by_path $person_node { { name fn } }]
            if { ![empty_string_p $formatted_name] || [string first " " $formatted_name] > -1 } {
                # Split, so everything up to the last space goes to first_names, the rest to last_name
                regexp {^(.+) ([^ ]+)$} $formatted_name match user_info(first_names) user_info(last_name)
            }
        }

        auth::sync::job::action \
            -job_id $job_id \
            -operation $operation \
            -username $username \
            -array user_info
    }

    # added IMS Ent stuff (roc)

    ims_enterprise::parser::group_to_dotlrn \
	-job_id $job_id \
	-document $document

    set authority_id [auth::sync::job::get_authority_id -job_id $job_id]

    ims_enterprise::parser::membership_to_dotlrn \
	-job_id $job_id \
	-authority_id $authority_id \
	-document $document

}
