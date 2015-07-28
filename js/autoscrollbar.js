//function used to enable or disable scroll bar and offset anchor links
function autoScroll() {
    if(Foundation.utils.is_small_only()) {  //if the window is a small window
        $("#actual-content").css({  "overflowY": "scroll" , "paddingTop": "45px" }); //using jQuery, get the content, set the height and set the overflowY mode
        //console.log("made small");  //log for dev
        $(".ancs").css({ "paddingTop": "45px" , "marginTop": "-45px" });    //if small screen, set margin and padding for anchors to avoid top "tab-bar"
    }

    if(Foundation.utils.is_medium_up()) {   //if the window is NOT small(medium or larger)
        $("#actual-content").css({ "overflowY": "visible" , "paddingTop": "0px" });  //set the height and overflowY
        //console.log("made not small");  //console log for dev
        $(".ancs").css({ "paddingTop": "0px" , "marginTop": "-0px" });  //if not small, remove padding and margin 
    }
}

//on load and on resize, enable or disable scroll bar
window.onload = function() {
    autoScroll();
    window.onresize = function() {
        autoScroll();
    };
};

