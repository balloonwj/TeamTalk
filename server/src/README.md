#编译说明
###编译环境
	TeamTalk编译需要依赖一些最新的c++标准, 建议使用CentOS 7.0, 如果使用的是CentOS 6.x,需要将g++版本升至支持c++11特性,升级脚本可以使用自动安装脚本目录下的gcc_setup

###第三方库
	TeamTalk使用了许多第三方库，包括protobuf,hiredis,mariadb(mysql),log4cxx等等,在第一次编译TeamTalk之前,建议先执行目录下的
		protobuf: make_protobuf.sh 
		hiredis: make_hiredis.sh
		mariadb: make_mariadb.sh
		log4cxx: make_log4cxx.sh
	这些脚本执行完后会自动将头文件和库文件拷贝至指定的目录
	
###编译TeamTalk服务器
	当以上步骤都完成后，可以使用"./build.sh version 1"编译整个TeamTalk工程,一旦编译完成，会在上级目录生成im_server_x.tar.gz包，该压缩包包含的内容有:
	sync_lib_for_zip.sh: 将lib目录下的依赖库copy至各个服务器的目录下，启动服务前需要先执行一次该脚本
	lib: 主要包含各个服务器依赖的第三方库
	restart.sh: 启动脚本，启动方式为./restart.sh msg_server
	login_server:
	msg_server:
	route_server:			
	db_proxy_server:
	file_server:
	push_server:
	msfs:
