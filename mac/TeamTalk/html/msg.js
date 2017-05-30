var msgRender  = {
	getUserById : function(id){	
		var user = JSON.parse(native.getUserById(id));
		var data = {
			name 		: user.Name,
			avatar_100 	: user.Avatar
		}
		return data;
	},
	update : function(id,status){
        $(".message-"+id).find(".message-status").removeClass("message-status-0").removeClass("message-status-1").removeClass("message-status-2").removeClass("message-status-3").addClass("message-status-"+status);
	},
	change : function(data){
		if(data.SessionID.indexOf('group')!=-1){
			sessionType = 'user';
		}else{
			sessionType = 'group';
		}
		return {
            id:data.ID,
			msgId:data.ServerID,
			sessionId: data.SessionID,
			fromUserId: data.SenderID,
			toUserId: data.TargetID,
			content: data.MessageContent,
			status: 1,
			msgTime: data.MessageTime,
			messageType: data.MessageType,
			sessionType: sessionType,
			info: ""
		}
	},
    render : function(msg,order,bottom){
    	var msg = JSON.parse(msg);
    	var msg = msgRender.change(msg);
    	// 判断当前这条时间和上一条时间相差多少.

		if(!order){
			var lastMsgTime = $(".J-chat-display .message:last").data('time');
			if(msg.msgTime - lastMsgTime > 5*60){
				$(".J-chat-display").append('<p class="message-alert-time">'+moment.unix(msg.msgTime).startOf('minute').calendar()+'</p>');
			}
		}else{
			var lastMsgTime = $(".J-chat-display .message:first").data('time');
    		if(lastMsgTime){
				if(lastMsgTime - msg.msgTime > 5*60){
//                    $(".debug").append($(".J-chat-display .message:first").text());
//                    $(".debug").append(msg.content+"</br>");
					$(".load-more-div").after('<p class="message-alert-time">'+moment.unix(lastMsgTime).startOf('minute').calendar()+'</p>');
				}
    		}
		}
        if(msg['fromUserId'] == window.ownerId){
            type = 'me';
        }else{
            type = 'other';
        }
        if(msg.messageType == 0){
        	msgRender.renderTextMsg(msg,type,order,bottom);
        }else{
        	msgRender.renderAudioMsg(msg,type,order,bottom);
        }
    },
	renderTextMsg : function(message,type,order,bottom){
		message.content_value = message.content.replace(/((?:(http|https|Http|Https|rtsp|Rtsp):\/\/(?:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,64}(?:\:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,25})?\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\:\d{1,5})?)(\/(?:(?:[a-zA-Z0-9\;\/\?\:\@\&\=\#\~\-\.\+\!\*\'\(\)\,\_])|(?:\%[a-fA-F0-9]{2}))*)?(?:\b|$)/gi, function(httpText) {
		    return '<a data-href="' + httpText + '" class="open_link" style="color:#0085e4;cursor:pointer;">' + httpText + '</a>';
		});

		function replaceImgTagInContent(content) {
		    xx = content.replace(/<img [^>]*src=['"]([^'"]+)[^>]*>/gi,function (match, url) {
		        if(match.indexOf("http://") != -1){
		            return match.replace(match, "<img src='");
		        }else{
		            return match;
		        }
		    });
		    return xx;
		}

		message.content_value = replaceImgTagInContent(message.content_value);
		message.content_value = message.content_value.replace(/<img [^>]*src=['"]([^'"]+)[^>]*>/gi,function (match, url) {
		    var re = match.replace("</a>","").replace('"',"'");
		    return re;
		});
		// $(".debug").text(message.content_value);
		var data = {
			type : type,
			user : msgRender.getUserById(message.fromUserId),
			message  : message
		};
		var html = template('J_Chat_Display_Text_Tpl', data);

		if(order){
			$(".load-more-div").after(html);
		}else{
			$(".J-chat-display").append(html);
			// 查看消息我是否是自己发的
			if(type == 'me'){
				setTimeout(function(){
					$(".J-chat-display").scrollTop(100000);
				},200)
			}else{			
				// 查看最后一条消息是否看得到
				var offset = $(".message:last").offset().top - $(".J-chat-display").height();
				if(offset < 100){
					$(".J-chat-display").scrollTop(100000);
				}else{
					$(".new-msg-alert").show();
				}
			}
		}
	},
	renderAudioMsg : function(message,type,order,bottom){
		if(native){		
			message.content = JSON.parse(message.content);
			var length = message.content.length;
			if(length>10){
				message.content.width = 200;
			}else{
				message.content.width = length /10 *200;
			}
			var data = {
				type : type,
				user : msgRender.getUserById(message.fromUserId),
				message  : message
			};
			var html = template('J_Chat_Display_Audio_Tpl', data);
			if(order){
				$(".load-more-div").after(html);
			}else{
				$(".J-chat-display").append(html);
				// 查看消息我是否是自己发的
				if(type == 'me'){
					$(".J-chat-display").scrollTop(100000);
				}else{			
					// 查看最后一条消息是否看得到
					var offset = $(".message:last").offset().top - $(".J-chat-display").height();
					if(offset < 100){
						$(".J-chat-display").scrollTop(100000);
					}else{
						$(".new-msg-alert").show();
					}
				}
			}
		}
	},
	htmlEncode:function(value){  
	  return $('<div/>').text(value).html();  
	},
	unix_to_datetime : function(unix) {
        var date = new Date(unix*1000);
        Y = date.getFullYear() + '-';
        M = (date.getMonth()+1 < 10 ? '0'+(date.getMonth()+1) : date.getMonth()+1) + '-';
        D = date.getDate() + ' ';
        h = date.getHours() + ':';
        m = date.getMinutes();
        s = date.getSeconds();
        return(Y+M+D+h+m);
//    	var now = new Date(parseInt(unix) * 1000);
//    	return now.toLocaleString().replace(/年|月/g, "-").replace(/日/g, " ");
	}
}