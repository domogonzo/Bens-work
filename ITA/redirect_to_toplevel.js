// This file requires toc.js.

document.addEventListener("DOMContentLoaded", function(event) {
	var toc_objects = toc_content();
	
	// Top level-item will always be toc_objects[0]
	top_level_url = toc_objects[0].url;
	
	// Replace and forward.
	window.location.assign(top_level_url);
});