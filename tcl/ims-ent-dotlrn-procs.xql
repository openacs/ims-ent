<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Rocael Hernandez Rizzardini (roc@viaro.net) -->
<!-- @creation-date 2004-04-05 -->
<!-- @arch-tag: A4594E0C-8730-11D8-865D-000A95ABB5AA -->
<!-- @cvs-id $Id$ -->

<queryset>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::department_check.get">
    <querytext>
      select count(*) from dotlrn_departments_full
      where department_key = :dep_id
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::department.update_department">
    <querytext>
      update dotlrn_departments
      set external_url = :external_url
      where department_key = :department_key
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::department.update_community_type">
    <querytext>
      update dotlrn_community_types
      set pretty_name = :pretty_name,
      description = :description
      where community_type = :department_key      
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::subject.update_community_type">
    <querytext>
      update dotlrn_community_types
      set pretty_name = :pretty_name,
      description = :description
      where community_type = :class_key      
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::department.n_classes">
    <querytext>
      select count(*)
      from dotlrn_classes
      where department_key = :department_key
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::subject_check.get">
    <querytext>
      select count(*)
      from dotlrn_community_types
      where community_type = :community_type
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::class.class_exist">
    <querytext>
      select count(*)
      from dotlrn_classes
      where class_key = :class_key
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::class.map_class">
    <querytext>
      insert into ims_ent_dotlrn_class_map (community_id, class_instance_key)
      values (:class_instance_id, :class_instance_key)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::get_community_id.get_comm_id">
    <querytext>
      select community_id from ims_ent_dotlrn_class_map
      where class_instance_key = :class_instance_key
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::ims_dotlrn::groups::guess_term.get_best_term">
    <querytext>
      select term_id
      from dotlrn_terms
      where start_date >= :start_date
      and end_date <= :end_date
      order by end_date DESC
      UNION
      select term_id
      from dotlrn_terms
      where end_date >= now()
      order by end_date DESC
      limit 1
    </querytext>
  </fullquery>

</queryset>