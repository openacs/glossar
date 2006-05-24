<?xml version="1.0"?>
<queryset>

<fullquery name="glossar_title">
    <querytext>
    select r.title as glossar_title
    from gl_glossars g, cr_revisions r, cr_items i
    where i.latest_revision = r.revision_id
    and g.glossar_id = r.revision_id
    and i.item_id = :glossar_id
    </querytext>
</fullquery>

<fullquery name="term_title">
    <querytext>
    select t.source_text as term_title
    from gl_glossar_terms t, cr_items i
    where i.latest_revision = t.term_id
    and i.item_id = :term_id
    </querytext>
</fullquery>

</queryset>
