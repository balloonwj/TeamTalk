// Setup the namespace
var pullToLoadHistory = {
    
	// Instance vars
eventCapable: true,
refreshCapable: false,
timeStarted: null,
scrollUpTime: null,
    
init: function () {
    // Inject the html onto the page
    $('.J-chat-display').prepend('<div id="pullToLoading"><span class="icon"></span><span class="text">载入中...</span></div><div id="pullToLoad"><div class="wrap"><span class="icon">&nbsp;</span><div id="pullyText">下拉载入更多</div></div></div>');
    
    // Bind scroll listener
    $(".J-chat-display").bind('scroll', pullToLoadHistory.monitorScroll);
},
    
monitorScroll: function () {
    console.log($(".J-chat-display").scrollTop());
    
    if ($(".J-chat-display").scrollTop() <= 0) {
        pullToLoadHistory.runScrollCommands();
        // console.log(11111);
        // window.WebViewController.scroll($(".J-chat-display").scrollTop());
    }
    
//    // If user is down the page, pull to refresh is not allowed
//    if ($(".J-chat-display").scrollTop() > 0) {
//        // reset the time
//        pullToLoadHistory.scrollUpTime = null;
//        pullToLoadHistory.eventCapable = false;
//    }
//    
//    if ($(".J-chat-display").scrollTop() === 0) {
//        // Start a timer if it isn't set
//        if (pullToLoadHistory.scrollUpTime === null) {
//            pullToLoadHistory.scrollUpTime = new Date();
//        }
//    }
//    
//    // User is real close, let's check that timer and see if it's long enough to load more history
//    if (pullToLoadHistory.scrollUpTime !== null)
//    {
//        var nowTime = new Date(),
//        diff = nowTime.getTime() - pullToLoadHistory.scrollUpTime.getTime();
//        
//        if (diff > 500) {
//            pullToLoadHistory.runScrollCommands();
//        }
//    }
//    else
//    {
//        pullToLoadHistory.runScrollCommands();
//    }
    
},
    
runScrollCommands: function () {
    console.log($(".J-chat-display").scrollTop());
    // Scrolling up has occured, but not enough to load more history yet
    if ($(".J-chat-display").scrollTop() < 0 && $(".J-chat-display").scrollTop() > -40)
    {
        // Set the text to pull to load more
        $("#pullToLoad #pullyText").html("下拉载入更多");
        
        if ($("#pullToLoad .icon").hasClass("flippedArrow")) {
            $("#pullToLoad .icon").removeClass("flippedArrow");
        }
        
        // Set the position of the pull down bar
        $("#pullToLoad").css({ top: Math.abs($(".J-chat-display").scrollTop()) - 40 });
        
        // Only set the time if we pull up and if the time is null
        if (pullToLoadHistory.refreshCapable === true && pullToLoadHistory.timeStarted === null) {
            // Set a date for scrolling back down the way
            pullToLoadHistory.timeStarted = new Date();
        }
    }
    
    // Load threshold has passed
    if ($(".J-chat-display").scrollTop() <= -40)
    {
        // Set the text and icon to release
        $("#pullToLoad #pullyText").html("松开即可载入");
        
        if ( ! $("#pullToLoad .icon").hasClass("flippedArrow")) {
            $("#pullToLoad .icon").addClass("flippedArrow");
            
        }
        
        // Set the position incase we scrolled too fast
        $("#pullToLoad").css({ top: 0 });
        
        // Set load capable
        pullToLoadHistory.refreshCapable = true;
        
        // Wipe out the time
        pullToLoadHistory.timeStarted = null;
    }
    
    // We're back down below the page, let's see if we can reload
    if ($(".J-chat-display").scrollTop() >= 0 && pullToLoadHistory.refreshCapable === true)
    {
        if (pullToLoadHistory.timeStarted !== null) {
            // Check the time
            var nowTime = new Date(),
            diff = nowTime.getTime() - pullToLoadHistory.timeStarted.getTime();
            
            // If we have taken less than a half second for the release, load more history
            if (diff < 500) {
                pullToLoadHistory.loadMoreHistory();
            }
        }
        else
        {
            // We haven't even got to set the time it was that fast, let's load more history.
            pullToLoadHistory.loadMoreHistory();
        }
        
        // Set the time back to null and set release capable back to false
        pullToLoadHistory.timeStarted = null;
        pullToLoadHistory.refreshCapable = false;
    }
    
    if ($(".J-chat-display").scrollTop() >= 0)
    {
        // Set the position to completely hidden again
        $("#pullToLoad").css({ top: -40 });
    }
    
},
    
loadMoreHistory: function () {
    console.log('loadMoreHistory');
    var messages = $("#list dl");
    var messageID = "", messageTimestamp = "";
    for (var i = 0; i < messages.length; i++) {
        messageID = $(messages[i]).attr('data-messageid');
        messageTimestamp = $(messages[i]).attr('data-messagetime');
        if (messageID && messageID != "" &&
            messageTimestamp && messageTimestamp != "") {
            break;
        }
    }
    if (messageID && messageID != "") {
        controller.loadMoreHistory(messageID, messageTimestamp);
    }
}
    
};

$(document).ready(pullToLoadHistory.init);