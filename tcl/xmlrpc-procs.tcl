# 

ad_library {
    
    for handling the communication via RPC
    
    @author Rocael Hernandez Rizzardini (roc@viaro.net)
    @creation-date 2004-06-10
    @arch-tag: AA9C688E-BB65-11D8-99F6-000A95ABB5AA
    @cvs-id $Id$
}

namespace eval ims_enterprise::sync::get_doc::xmlrpc::GetDocument {}

ad_proc -private ims_enterprise::sync::get_doc::xmlrpc::GetParameters {} {
    Parameters for HTTP GetDocument implementation.
} {
    return {
	RPCServerURL {The URL of the xml-rpc server, including where the rpc responds.}
        IncrementalProc {The remote procedure name for Incremental IMS XML documents.}
        SnapshotProc {The remote procedure name for Snapshot IMS XML documents.}
    }
}

ad_proc -private ims_enterprise::sync::get_doc::xmlrpc::GetDocument {
    parameters
} {
    Retrieve the document by XML-RPC
} {
    array set result {
        doc_status failed_to_conntect
        doc_message {}
        document {}
        snapshot_p f
    }
    
    array set param $parameters
    
    if { (![empty_string_p $param(SnapshotProc)] && [string equal [clock format [clock seconds] -format "%d"] "01"]) || \
             [empty_string_p $param(IncrementalProc)] } {

        # On the first day of the month, we get a snapshot
        set proc $param(SnapshotURL)
        set result(snapshot_p) "t"
    } else {
        # All the other days of the month, we get the incremental
        set proc $param(IncrementalURL)
    }

    set url $param(RPCServerURL)

    if { [empty_string_p $url] } {
        error "You must specify the URL of the XML-RPC server."
    }

    if { [empty_string_p $proc] } {
        error "You must specify at least one remote procedure to call."
    }


    catch {xmlrpc::remote_call $url $proc} result(document)

    # we need to check if the document returned its a valid one!

    set result(doc_status) "ok"

    return [array get result]
}

