function highlight_existing(textfield) {
    field = document.getElementById(textfield)
    tagstring = field.value;
    tags = tagstring.split(", ")
    tags.each(function(tag){
	tag_link = get_tag_link(textfield, tag);
	tag_link.className = "tag_highlight";
    })
}

function get_tag_link(textfield, tag) {
    return document.getElementById(tag + "_" + textfield);
}

function tag_swap(tag, textfield) {
  field = document.getElementById(textfield);
  val = field.value
  orig_val = val
  tag_link = document.getElementById(tag + "_" + textfield);
  regxp = new RegExp( tag + ',*\\s*');
  if(val.indexOf(tag) != -1)  {
      val = val.replace(regxp, " ");
    tag_link.className = "tag";
  } else {
      if(val == ''){
          punct = ''
      } else {
          punct = ", "
      }
    val += (punct + tag);
    tag_link.className = "tag_highlight";
  }
  val = val.replace(/\s{2}/, " ");
  val = val.replace(/,\s*$/, "");
  field.value = val.replace(/(^\s*,\s*|^\s*)/, "");
}

function old_tag_swap(tag, textfield) {
  field = document.getElementById(textfield);
  val = field.value
  tag_link = document.getElementById(tag + "_" + textfield);
  if(pad(val).indexOf(pad(tag)) != -1)  {
    val = pad(val).replace(pad(tag), " ");
    tag_link.className = "tag";
  } else {
    val += pad(tag);
    tag_link.className = "tag_highlight";
  }
  field.value = val.replace(/\s{2,}/, " ");
}

function tag_swap_x(tag, textfield) {
  field = document.getElementById(textfield);
  val = field.value
  var tag_link = document.getElementById(tag + "_" + textfield);
  if(pad(val).indexOf(pad(tag)) != -1)  {
    val = pad(val).replace(pad(tag), " ");
    tag_link.className = "tag";
  } else {
    unhighlight_all(val, textfield);
    val = pad(tag);
    tag_link.className = "tag_highlight";
  }
  field.value = val.replace(/\s{2,}/, " ");
}

function unhighlight_all(text, textfield) {
  tags = text.split(", ");
  highlit = [];
  for (i in tags) {
    var tag_link = document.getElementById(tags[i] + "_" + textfield);
    if(tag_link) {
      highlit.push(tag_link);
    }
  }
  for (i in highlit) {
      highlit[i].className = "tag";
  }
}

function pad(str) {
  return str + " ";
}

function delete_list_item(id, delete_action) {
  if (confirm("Delete: Are you sure?")) {
    window.location = delete_action + "/" + id;
  };
}