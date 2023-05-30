/* This file uses JQuery to alter the formatting of a topic
 * when the reader loads the topic in the CHM. This fixes multiple
 * display and layout issues that occur as a result of either a CHM
 * or an Author-IT limitation.
 */

$(document).ready(function() {
	/*****************************************************
	Remove static width attributes from tables, then set
	the tables to expand to 100%.
	Leaves td and th width attributes alone.
	(Fixes word-wrapping and text aligmnent in tables)
	
	NOTE: Intentionally commented out on 2014-10-13. Tables 
	will publish WYSIWYG from Author-IT. This may be rolled 
	back at a future date for a more width-responsive design.
	******************************************************/
	/*
	$('table.tableintopic').removeAttr('width');
	$('table.tableintopic').css('width', '100%');
	*/
	
	
	/******************************************************
	Add margin for tables that are children of li objects.
	*******************************************************/
	$('li > table.tableintopic').each(function(){
		$(this).css('margin-top', '6pt');
	});
	
	/******************************************************
	Tables should always indent with the previous content.
	*******************************************************/
	$('table.tableintopic').each(function() {
		var prev_margin_left = $(this).prev().css('margin-left');
		$(this).css('margin-left', prev_margin_left);
	});
	
	/******************************************************
	When a bullet list is beneath another list (cascading),
	set the margin-left from its default wide value to 0pt.
	This fixes inconsistent bullet indentations between when 
	a list is properly cascaded and when a level 2 or 
	higher list is used as a standalone list.
	*******************************************************/
	
	// The comma and extra space at the end of 
	// all lines but the last is important.
	var cascaded_bullets =  "li > ul.listbullet2, ";
	    cascaded_bullets += "li > ul.listbullet3, ";
		cascaded_bullets += "li > ul.listbullet4";
		
	$(cascaded_bullets).css('margin-left', '0pt');
	
	/******************************************************
	When a numbered or alphabetic list is beneath another 
	list (cascading), set the margin-left from its default 
	wide value to 0pt. This fixes inconsistent list 
	indentations between when a list is properly cascaded 
	and when a level 2 or higher list is used as a 
	standalone list.
	*******************************************************/

	// The comma and extra space at the end of 
	// all lines but the last is important.	
	var cascaded_num_alpha =  "li > ol.listnumber2, ";
		cascaded_num_alpha += "li > ol.listalpha, ";
		cascaded_num_alpha += "li > ol.listalpha2, ";
		cascaded_num_alpha += "li > ol.listalpha2";
	
	$(cascaded_num_alpha).css('margin-left', '0pt');
	
	/******************************************
	Change all <h2> through <h7> tags to <h1> tags
	*******************************************/		
	$(function () {
	  var title,
		  headerToReplace,
		  replaceHeaderWith;

	  if ( $('h1').length === 0 ) {
		title = document.title;
		headerToReplace = $(':header').filter(function () {
		  return $(this).text() === title;
		});

		if (headerToReplace.length) {
		  replaceHeaderWith = $('<h1 />', { 'class': 'heading1', text: title });
		  headerToReplace.first().replaceWith(replaceHeaderWith);
		}
	  }
	});
	
	/******************************************
	Remove empty bullets (unordered list items)
	*******************************************/
	$('ul li:empty').remove();

	/*******************************
	Remove Tooltips from Popup links
	********************************/
    $('#main a').mouseover(function () {
        $this = $(this);
        $this.data('title', $this.attr('title'));
		$this.data('alt', $this.attr('alt'));
        $this.attr('title', '');
		$this.attr('alt', '');
    }).mouseout(function () {
        $this = $(this);
        $this.attr('title', $this.data('title'));
		$this.attr('alt', $this.data('alt'));
	});
});