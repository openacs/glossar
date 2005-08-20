# packages/glossar/lib/glossar-term-list.tcl
#
# Lists all Terms from one Glossar
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-10
# @arch-tag: beb88796-955e-4cbd-af5e-3919597c7ed1
# @cvs-id $Id$

foreach required_param {glossar_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {page orderby upload_count} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {![info exists upload_count]} {
    set upload_count "1"
}

if {![info exists orderby]} {
    set order_by  "file,asc"
}

if {$upload_count != 10} {
    set upload_count 1
}

set folder_id [application_data_link::get_linked \
		   -from_object_id $glossar_id \
		   -to_object_type "content_folder"]



set form_elements [list {glossar_id:integer(hidden)}]
lappend form_elements [list {upload_count:integer(hidden)}]
lappend form_elements [list {orderby:text(hidden),optional}]
set upload_number 1

while {$upload_number <= $upload_count} {
    lappend form_elements [list "upload_file${upload_number}:file(file),optional" [list label ""] [list section "section$upload_number"]]
    lappend form_elements [list "upload_title${upload_number}:text(text),optional" [list html "size 45 maxlength 100"] [list label ""]]
    incr upload_number
}

if {$upload_count == 1} {set upload_label "Upload" } else {set upload_label "[_ glossar.glossar_Done]" }

lappend form_elements [list "upload:text(submit),optional" [list "label" $upload_label]]
lappend form_elements [list "upload_more:text(submit),optional" [list "label" "[_ glossar.Upload_More]"]]

ad_form -name upload_files -html {enctype multipart/form-data} -form $form_elements -on_request {
} -on_submit {
    set upload_number 1
    set message [list]
    while {$upload_number <= $upload_count} {
	set file [set "upload_file${upload_number}"]
	set title [set "upload_title${upload_number}"]
	set filename [template::util::file::get_property filename $file]
	if {$filename != "" } {
	    set tmp_filename [template::util::file::get_property tmp_filename $file]
	    set mime_type [template::util::file::get_property mime_type $file]
	    set tmp_size [file size $tmp_filename]
	    set extension [contact::util::get_file_extension \
			       -filename $filename]
	    if {![exists_and_not_null title]} {
		regsub -all ".${extension}\$" $filename "" title
	    }
	    set filename "$filename"

	    set revision_id [cr_import_content \
				 -storage_type "file" -title $title $glossar_id $tmp_filename $tmp_size $mime_type $filename]

	    content::item::set_live_revision -revision_id $revision_id

	    # if the file is an image we need to create thumbnails
	    # #/sw/bin/convert -gravity Center -crop 75x75+0+0 fred.jpg fred.jpg
	    # #/sw/bin/convert -gravity Center -geometry 100x100+0+0 04055_7.jpg
	    # fred.jpg

	    lappend message "<a href=\"files/$filename\">$title</a>"
	}
	incr upload_number
    }
    if {[llength $message] == 1} {
	set message [lindex $message 1]
	util_user_message -html -message "[_ glossar.lt_The_file_lindex_messa]"
    } elseif {[llength $message] > 1} {
	set message [join $message ", "]
	util_user_message -html -message "[_ glossar.lt_The_files_join_messag]"
    }
} -after_submit {
    if {[exists_and_not_null upload_more]} {
	ad_returnredirect [export_vars \
			       -base "glossar-file-upload" -url {{upload_count 10 glossar_id}}]
    } else {
	ad_returnredirect "glossar-file-upload?glossar_id=$glossar_id"
    }
    ad_script_abort
}

template::list::create \
    -html {width 100%} \
    -name "files" \
    -multirow "files" \
    -row_pretty_plural "[_ glossar.files]" \
    -checkbox_name checkbox \
    -bulk_action_export_vars [list glossar_id orderby] \
    -bulk_actions [list \
	"[_ glossar.Delete]" "glossar-file-delete" "[_ glossar.lt_Delete_the_selectted_]" \
	"[_ glossar.Update]" "glossar-file-update" "[_ glossar.Update_filenames]" \
		   ] \
    -selected_format "normal" \
    -key item_id \
    -elements {
	file {
	    label {File}
	    display_col title
	    link_url_eval $file_url
	}
	rename {
	    label {Rename}
	    display_template {<input name="rename.@files.item_id@" value="@files.title@" size="30">
	    }
	}
	type {
	    label "[_ glossar.Type]"
	    display_col extension
	}
	creation_date {
	    label "[_ glossar.Updated_On]"
	    display_col creation_date_pretty
	}
	creation_user {
	    label "[_ glossar.Updated_By]"
	    display_col creation_user_pretty
	}
    } -filters {
    } -orderby {
	file {
	    label "[_ glossar.File]"
	    orderby_asc  "upper(cr.title) asc,  ao.creation_date desc"
	    orderby_desc "upper(cr.title) desc, ao.creation_date desc"
	    default_direction asc
	}
	creation_date {
	    label "[_ glossar.Updated_On]"
	    orderby_asc  "ao.creation_date asc"
	    orderby_desc "ao.creation_date desc"
	    default_direction desc
	}
	creation_user {
	    label "[_ glossar.Updated_By]"
	    orderby_asc  "upper(contact__name(ao.creation_user)) asc, upper(cr.title) asc"
	    orderby_desc "upper(contact__name(ao.creation_user)) desc, upper(cr.title) asc"
	    default_direction desc
	}
	default_value file,asc
    } -formats {
	normal {
	    label "[_ glossar.Table]"
	    layout table
	    row {
	    }
	}
    }

set package_url [ad_conn package_url]
db_multirow -extend {file_url extension} -unclobber files select_files "select ci.item_id,
       ci.name,
       cr.title,
       to_char(ao.creation_date,'FMMon DD FMHH12:MIam') as creation_date_pretty,
       contact__name(ao.creation_user) as creation_user_pretty
  from cr_items ci, cr_revisions cr, acs_objects ao
 where ci.parent_id = :glossar_id
   and ci.live_revision = cr.revision_id
   and cr.revision_id = ao.object_id
[template::list::orderby_clause \
     -orderby \
     -name "files"]" {
     set file_url "${package_url}${glossar_id}/files/${name}"
     set extension [lindex [split $name "."] end]
    }
if {![empty_string_p $folder_id]} {
    set package_id [lindex [fs::get_folder_package_and_root $folder_id] 0]
    set base_url [apm_package_url_from_id $package_id]
}


