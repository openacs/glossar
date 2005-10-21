<table width="100%">
<tr>
   <td valign="top">
	<form method="ge"t name="term-list-search"  action="glossar-term-list">
	  #glossar.Search#:<br />
	  <input type="text" name="searchterm" value="@searchterm@" size="12" />
	 @hidden_vars;noquote@ 
	 <input type="submit" name="go" value="Go" />
	</form>
   </td>
   <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
   <td>
	<table>
	<tr>
	    <td><b>#glossar.Title#:</b></td>
	    <td> @glossar_title@</td>
	</tr>
	<tr>
	    <td><b>#glossar.Comment#:</b></td>
	    <td> @glossar_comment;noquote@ </td>
	</tr>
	<tr>
	    <td><b>#glossar.glossar_single_category#:</b></td>
	    <td> @glossar_language;noquote@ </td>
	</tr>
	<tr>
	    <td><b>#glossar.glossar_target_category#:</b></td>
	    <td> @glossar_target_lan;noquote@ </td>
	</tr>
	<tr>
	    <td><b>#glossar.Files#:</b></td>
	    <td> @files;noquote@ </td>
	</tr>
	</table>
   </td>
</tr>
</table>
<br />

<listtemplate name="gl_term"></listtemplate>
  
