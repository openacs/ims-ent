<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Rocael Hernandez Rizzardini (roc@viaro.net) -->
<!-- @creation-date 2004-03-28 -->
<!-- @arch-tag: F6F1475B-812A-11D8-9D2E-000A95ABB5AA -->
<!-- @cvs-id $Id$ -->

<queryset>

  <fullquery name="ims_enterprise::parser::group.insert_group">
    <querytext>
	insert into ims_ent_groups (ims_ent_group_id, recstatus)
	values (:ims_ent_group_id, :recstatus)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.select_lang_id">
    <querytext>
      select ims_ent_lang_id from ims_ent_langs
      where lang = :lang
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_comment">
    <querytext>
      insert into ims_ent_comments (ims_ent_comment_id, ims_ent_tag_id, tag_type, comments)
      values (:ims_ent_comment_id, :ims_ent_tag_id, :tag_type, :comments)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_comment_lang_map">
    <querytext>
      insert into ims_ent_comm_lang_map (ims_ent_comment_id, ims_ent_lang_id)
      values (:ims_ent_comment_id, :ims_ent_lang_id)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_sourcedid">
    <querytext>
      insert into ims_ent_sourcedids (ims_ent_sourcedid_id, ims_ent_tag_id, tag_type, sourcedidtype, source, id)
      values (:ims_ent_sourcedid_id, :ims_ent_tag_id, :tag_type, :sourcedidtype, :source, :id)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_grouptype">
    <querytext>
      insert into ims_ent_gr_grouptypes (ims_ent_gr_grouptype_id, ims_ent_group_id, scheme)
      values (:ims_ent_gr_grouptype_id, :ims_ent_group_id, :scheme)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_typevalue">
    <querytext>
      insert into ims_ent_gr_typevalues (ims_ent_gr_typevalue_id, ims_ent_gr_grouptype_id, typevalue, level)
      values (:ims_ent_gr_typevalue_id, :ims_ent_gr_grouptype_id, :typevalue, :level)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_description">
    <querytext>
      insert into ims_ent_gr_descriptions (ims_ent_gr_description_id, ims_ent_group_id, short, long, full_name)
      values (:ims_ent_gr_description_id, :ims_ent_group_id, :short, :long, :full)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_timeframe">
    <querytext>
      insert into ims_ent_timeframes (ims_ent_timeframe_id, ims_ent_tag_id, tag_type, begin_date, begin_restrict, end_date, end_restrict, adminperiod)
      values (:ims_ent_timeframe_id, :ims_ent_tag_id, :tag_type, :begin_date, :begin_restrict, :end_date, :end_restrict, :adminperiod)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_enrollcontrol">
    <querytext>
      insert into ims_ent_gr_enrollcontrols (ims_ent_gr_enrollcontrol_id, ims_ent_group_id, enrollaccept, enrollallowed)
      values (:ims_ent_gr_enrollcontrol_id, :ims_ent_group_id, :enrollaccept, :enrollallowed)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_email">
    <querytext>
      insert into ims_ent_emails (ims_ent_email_id, ims_ent_tag_id, tag_type, email)
      values (:ims_ent_email_id, :ims_ent_tag_id, :tag_type, :email)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_url">
    <querytext>
      insert into ims_ent_urls (ims_ent_url_id, ims_ent_tag_id, tag_type, url)
      values (:ims_ent_url_id, :ims_ent_tag_id, :tag_type, :url)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_relationship">
    <querytext>
      insert into ims_ent_gr_relationships (ims_ent_gr_relationship_id, ims_ent_group_id, relation, sourcedid, label)
      values (:ims_ent_gr_relationship_id, :ims_ent_group_id, :relation, :sourcedid, :label)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group.insert_datasource">
    <querytext>
      insert into ims_ent_datasources (ims_ent_datasource_id, ims_ent_tag_id, tag_type, datasource)
      values (:ims_ent_datasource_id, :ims_ent_tag_id, :tag_type, :datasource)
    </querytext>
  </fullquery>

  <fullquery name="ims_enterprise::parser::group_to_dotlrn.class_key">
    <querytext>
      select class_key from dotlrn_classes_full where trim(class_key) like '%.$parent_key'
	limit 1
    </querytext>
  </fullquery>
</queryset>