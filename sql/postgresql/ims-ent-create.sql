-- 
-- 
-- 
-- @author Rocael Hernandez Rizzardini (roc@viaro.net)
-- @creation-date 2004-04-06
-- @arch-tag: A4D2DD30-8839-11D8-9819-000A95ABB5AA
-- @cvs-id $Id$
--
-- we'll use this to identify the relation with a given community_id (class)
-- and the <id> that comes in <group> for a give class

create table ims_ent_dotlrn_class_map (
	class_instance_key	varchar(256)
				constraint ms_ent_dotlrn_class_map_pk
				primary key,
	community_id		integer 
				constraint ims_ent_dotlrn_class_map_comm_id
				references dotlrn_communities_all (community_id)
);


alter table auth_batch_job_entries add community_key varchar(100);
alter table auth_batch_job_entries add department_key varchar(100);
alter table auth_batch_job_entries add subject_key varchar(100);
alter table auth_batch_job_entries add class_key varchar(100);
alter table auth_batch_job_entries add class_instance_key varchar(100);
