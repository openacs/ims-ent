ad_page_contract {
    Display all information about a certain batch import operation.

    @author Peter marklund (peter@collaboraid.biz)
    @creation-date 2003-09-10
} {
    entry_id:integer
}

ims_enterprise::sync::job::get_entry -entry_id $entry_id -array batch_action
auth::sync::job::get -job_id $batch_action(job_id) -array batch_job

set page_title "One batch action"

set context [list \
                  [list [export_vars -base authority { {authority_id $batch_action(authority_id)} }] \
                        "$batch_job(authority_pretty_name)"] \
                  [list [export_vars -base batch-job {{job_id $batch_action(job_id)}}] "One batch job"] \
                 $page_title]

ad_form -name batch_action_form \
        -mode display \
        -display_buttons {} \
        -form {
            {entry_time:text(inform)
                {label "Timestamp"}
            }
            {operation:text(inform)
                {label "Action type"}
            }
            {username:text(inform)
                {label "Username"}
            }
            {user_id:text(inform)
                {label "User"}
            }
            {community_key:text(inform)
                {label "Community Key"}
            }
            {department_key:text(inform)
                {label "Department Key"}
            }
            {subject_key:text(inform)
                {label "Subject Key"}
            }
            {class_key:text(inform)
                {label "Class Key"}
            }
            {class_instance_key:text(inform)
                {label "Class Instance Key"}
            }
            {success_p:text(inform)
                {label "Success"}
            }
            {message:text(inform)
                {label "Message"}
            }
            {element_messages:text(inform)
                {label "Element messages"}
            }            
        } -on_request {
            foreach element_name [array names batch_action] {
                # Prettify certain elements
                if { [regexp {_p$} $element_name] } {
                    set $element_name [ad_decode $batch_action($element_name) "t" "Yes" "No"]
                } elseif { [string equal $element_name "user_id"] && ![empty_string_p $batch_action($element_name)] } {
                    if { [catch {set $element_name [acs_community_member_link -user_id $batch_action($element_name)]}] } {
                        set $element_name $batch_action($element_name)
                    }
                } elseif { [string equal $element_name "element_messages"] && ![empty_string_p $batch_action($element_name)] } {
                    array set messages_array $batch_action($element_name)
                    append $element_name "<ul>"
                    foreach message_name [array names messages_array] {
                        append $element_name "<li>$message_name - $messages_array($message_name)</li>"
                    }
                    append $element_name "</ul>"
                } elseif { [string equal $element_name "department_key"] && ![empty_string_p $batch_action($element_name)] } {
		    set dep_key $batch_action($element_name)
                    if { [catch {set $element_name "<a href=\"[dotlrn::get_url]/admin/department?department_key=$batch_action($element_name)\">$batch_action($element_name)</a>"}] } {
                        set $element_name $batch_action($element_name)
                    }
                } elseif { [string equal $element_name "subject_key"] && ![empty_string_p $batch_action($element_name)] } {
                    if { [catch {set $element_name "<a href=\"[dotlrn::get_url]/admin/class?class_key=${dep_key}.$batch_action($element_name)\">$batch_action($element_name)</a>"}] } {
                        set $element_name $batch_action($element_name)
                    }
                } elseif { [string equal $element_name "class_instance_key"] && ![empty_string_p $batch_action($element_name)] } {
                    if { [catch {set $element_name "<a href=\"[dotlrn_community::get_community_url [ims_enterprise::ims_dotlrn::get_community_id $batch_action($element_name)]]\">$batch_action($element_name)</a>"}] } {
                        set $element_name $batch_action($element_name)
                    }
                } else {
                    set $element_name $batch_action($element_name)
                }
            }
        }
