var global = window;
$(function(){
    if(window.initDataInfo !== undefined){
        msgRender.init(JSON.parse(initDataInfo),JSON.parse(initDataHistoryMsg));
    }else{
    	var info = {
			id 			: 656,
			name 		: '周盛伟',
			pyname		: 'xiezi',
			nick 		: '蝎紫',
			avatar      : 'http://s7.mogujie.com/b7/avatar/140818/7ps_ieydcyzqmnrtkzlcmiytambqgiyde_615x615.jpg',
			avatar_100  : 'http://s7.mogujie.com/b7/avatar/140818/7ps_ieydcyzqmnrtkzlcmiytambqgiyde_615x615.jpg_100x100.jpg',
			avatar_200  : 'http://s7.mogujie.com/b7/avatar/140818/7ps_ieydcyzqmnrtkzlcmiytambqgiyde_615x615.jpg_200x200.jpg',
			department 	: 'SWAT(IM)',
			departId 	: '',
			email 		: 'xiezi@mogujie.org',
			position 	: '',
			telphone 	: '15068808683',
			sex 		: 1,
			sex_value 	: '男',
			status		: 0
		};
		var historyMsg = [{
			id: 5,
			msgId: 90,
			sessionId: '554',
			fromUserId: '554',
			toUserId: '656',
			content: '111111&$#@~^@[{:http://s1.dwstatic.com/group1/M00/E1/86/fc9b4d5cbfcf646fb807186649e54dcf.gif:}]&$~@#@22222&$#@~^@[{:http://s1.dwstatic.com/group1/M00/E1/86/fc9b4d5cbfcf646fb807186649e54dcf.gif:}]&$~@#@333222&$#@~^@[{:http://s1.dwstatic.com/group1/M00/E1/86/fc9b4d5cbfcf646fb807186649e54dcf.gif:}]&$~@#@333222&$#@~^@[{:http://s1.dwstatic.com/group1/M00/E1/86/fc9b4d5cbfcf646fb807186649e54dcf.gif:}]&$~@#@333222&$#@~^@[{:http://s1.dwstatic.com/group1/M00/E1/86/fc9b4d5cbfcf646fb807186649e54dcf.gif:}]&$~@#@33333&$#@~^@[{:http://101.68.210.105:8001/g0/000/000/1420725220582953_140724933523.png:}]&$~@#@4444z',
			status: 2,
			msgTime: 1420892913,
			sessionType: 1,
			messageType: 1,
			info: '',
			avatar_100:'http://s7.mogujie.com/b7/avatar/140515/32q_kqzhqwckl5bf6rkugfjeg5sckzsew_480x640.jpg_100x100.jpg', 
		}, { id: 33,
		    msgId: 62,
		    sessionId: '554',
		    fromUserId: '656',
		    toUserId: '554',
		    content: '代表aahsahd',
		    status: 2,
		    msgTime: 1420888614,
		    sessionType: 1,
		    messageType: 1,
		    info: '',
		}, { id: 34,
		    msgId: 61,
		    sessionId: '554',
		    fromUserId: '554',
		    toUserId: '656',
		    content: '是不是你呢',
		    status: 2,
		    msgTime: 1420888611,
		    sessionType: 1,
		    messageType: 1,
		    info: '',
		}, { id: 38,
		    msgId: 11,
		    sessionId: '554',
		    fromUserId: '656',
		    toUserId: '554',
		    content: '',
		    status: 2,
		    msgTime: 1420888611,
		    sessionType: 1,
		    messageType: 2,
		    info: {
		    	length : 10
		    },
		},{ id: 34,
		    msgId: 61,
		    sessionId: '554',
		    fromUserId: '554',
		    toUserId: '656',
		    content: '',
		    status: 2,
		    msgTime: 1420888611,
		    sessionType: 1,
		    messageType: 2,
		    info: {
		    	length: 11
		    },
		}];
		var xx = [];
		var i = 1;
		while(i<10){
			xx.push(historyMsg[i%5]);
			i++;
		}
		msgRender.init(info,xx);
		$('.load-more').hook({
			reloadPage: false,
			reloadEl: function(){
				console.log('Hello World!');
			}
		});
    }
})
var msgRender  = {
	init : function(info,historyMsg){
		this.setOwnerInfo(info);
        for(i in historyMsg){
            this.render(historyMsg[i]);
        }
	},
	setOwnerInfo : function(info){
		global.TTOwner = info;
	},
	getUserById : function(id){
		var allUser = {
			554 :{
				name       : '东邪',
				avatar		: 'http://s7.mogujie.com/b7/avatar/140515/32q_kqzhqwckl5bf6rkugfjeg5sckzsew_480x640.jpg',
				avatar_100	: 'http://s7.mogujie.com/b7/avatar/140515/32q_kqzhqwckl5bf6rkugfjeg5sckzsew_480x640.jpg_100x100.jpg',
			},
			656 :{
				name       : '蝎紫',
				avatar		: 'http://s7.mogujie.com/b7/avatar/140818/7ps_ieydcyzqmnrtkzlcmiytambqgiyde_615x615.jpg_100x100.jpg',
				avatar_100	: 'http://s7.mogujie.com/b7/avatar/140818/7ps_ieydcyzqmnrtkzlcmiytambqgiyde_615x615.jpg',
			}
		};
		return allUser[id];
	},
	change : function(data){
		return {
			id: data.id,
			msgId:data.msgId,
			sessionId: data.sessionId,
			fromUserId: data.fromUserId,
			toUserId: data.toUserId,
			content: data.content,
			status: data.status,
			msgTime: data.msgTime,
			sessionType: data.sessionType,
			messageType: data.messageType,
			info: data.info
		}
	},
    render : function(msg){
    	// 判断当前这条时间和上一条时间相差多少.
    	var lastMsgTime = $(".J-chat-display .message:last").data('time');
    	if(msg.msgTime - lastMsgTime > 5*60){
    		$(".J-chat-display").append('<p class="message-alert-time">'+global.unix_to_datetime(msg.msgTime)+'</p>');
    	}

        if(msg['fromUserId'] == global.TTOwner.id){
            type = 'me';
        }else{
            type = 'other';
        }
        if(msg.messageType == 1 || msg.messageType == 17){
        	msgRender.renderTextMsg(msg,type);
        }else{
        	msgRender.renderAudioMsg(msg,type);
        }
    },
	renderTextMsg : function(message,type){
		var content_value = message.content;
		message.content_value = content_value;
		var data = {
			user : msgRender.getUserById(message.fromUserId),
			message  : message
		};
		var html = template('J_Chat_Display_'+type+'_Tpl', data);
		$(".J-chat-display").append(html);
		$(".J-chat-display").scrollTop($(".J-chat-display")[0].scrollHeight);
		$(".chat-content").scrollTop(100000);
	},
	renderAudioMsg : function(message,type){
		var data = {
			user : msgRender.getUserById(message.fromUserId),
			message  : message
		};
		var html = template('J_Chat_Display_Audio_'+type+'_Tpl', data);
		$(".J-chat-display").append(html);
		$(".J-chat-display").scrollTop($(".J-chat-display")[0].scrollHeight);
		$(".chat-content").scrollTop(100000)
	}
}




































