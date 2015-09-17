function choose_image(image_id, field_prefix) {

  window.opener.document.getElementById(field_prefix + "_image_id").value = image_id;
  new Ajax.Updater('nothing', "/settings/image_url/" + image_id, 
		   {asynchronous:true, 
		       evalScripts:true, 
		       onComplete:function(request){
		           window.opener.document.getElementById(field_prefix + "_thumbnail").src = request.responseText;}});
  false;
};
