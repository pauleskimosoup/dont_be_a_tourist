function fileBrowserCallBack(field_name, url, type, win) {
        var connector = "/javascripts/tiny_mce/filemanager/browser.html?Connector=/file_manager/command";
        var enableAutoTypeSelection = true;

        var cType;
        tinyfck_field = field_name;
        tinyfck = win;

        switch (type) {
                case "image":
                        cType = "Image";
                        break;
                case "flash":
                        cType = "Flash";
                        break;
                case "file":
                        cType = "File";
                        break;
        }

        if (enableAutoTypeSelection && cType) {
                connector += "&Type=" + cType;
        }

        window.open(connector, "tinyfck", "modal,width=600,height=400");
}

tinyMCE.init({
    theme:"advanced",
    mode:"textareas",
    width:"98%",
    height:"400px",
    plugins:"inlinepopups,paste,tmediaimage,tmediadocument",
    theme_advanced_toolbar_location : "top",
    theme_advanced_buttons1:"bold,italic,underline,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,bullist,numlist,styleselect,formatselect",
    theme_advanced_buttons2:"undo,redo,link,unlink,tmediaimage,tmediadocument,pasteword,code",
    theme_advanced_buttons3:"",
    theme_advanced_blockformats:"p, h1, h2, h3",
    content_css:"/stylesheets/tnymc.css",
    external_link_list_url:"/file_manager/link_list",
    document_base_url:"/images/gallery/",
    relative_urls:false,
    file_browser_callback : "fileBrowserCallBack",
    editor_selector:"mceEditor"
});