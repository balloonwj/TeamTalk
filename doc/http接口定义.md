## http协议定义
	
	1.创建群组
	/query/CreateGroup
	
	请求:
	{
    "req_user_id": 0,
    "app_key": "asdfasdf",
    "group_name": "abc",
    "group_type": 1,           #GROUP_TYPE_NORMAL=1, GROUP_TYPE_TMP=2
    "group_avatar": "sdafdsf",
    "user_id_list": [
        1,
        2,
        3,
        4,
        5
    ]
	}
	
	响应:
	{
	"error_code": 0,
	"error_msg": "xxx",
	"group_id": 1
	}
	
***
	
	2.更改成员
	/query/ChangeMembers
	
	请求:
	{
    "req_user_id": 0,
    "app_key": "asdfasdf",
    "group_id": 1,
    "modify_type": 2,                #1:add  2:del
    "user_id_list": [
        1,
        2,
        3,
        4,
        5
    ]
	}
	
	响应:
	{
	"error_code": 0,
	"error_msg": "xxx"
	}
	