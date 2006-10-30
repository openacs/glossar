<table width="100%">
<tr>
   <if @layout_for_printing@ not eq 1>
   <td valign="top">
	<form method="get" name="term-list-search"  action="glossar-term-list">
	  #glossar.Search#:<br />
	  <input type="text" name="searchterm" value="@searchterm@" size="12" />
	 @hidden_vars;noquote@ 
	 <input type="submit" name="go" value="Go" />
	</form>
   </td>
   <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
   <td>
   </if>
	<table>
	<tr>
	    <td><b>#glossar.glossar_single_category#:</b></td>
	    <td> @glossar_language;noquote@ </td>
	</tr>
        <if @glossar_target_lan@ not nil>
	<tr>
	    <td><b>#glossar.glossar_target_category#:</b></td>
	    <td> @glossar_target_lan;noquote@ </td>
	</tr>
        </if>
	<tr>
	    <td><b>#glossar.Comment#:</b></td>
	    <td> <b> @glossar_comment;noquote@ </b> </td>
	</tr>
        <if @files:rowcount@ gt 0>
	<tr>
	    <td><b>#glossar.Files#:</b></td>
	    <td>
              <multiple name=files>
                <a href="download/@files.name@?file_id=@files.item_id@" title="@files.name@">@files.name@</a><br>
              </multiple>
            </td>
	</tr>
        </if>
	</table>
   </td>
</tr>
</table>
<br />

<listtemplate name="gl_term"></listtemplate>
