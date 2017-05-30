<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>TT开源php管理后台 | 登陆</title>
        <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
        <script src="/ui/js/jquery-1.11.1.min.js"></script>
        <link href="/ui/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <link href="/ui/css/main.css" rel="stylesheet" type="text/css" />

        <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
          <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
        <![endif]-->
    </head>
    <body>
        <script type="text/javascript">
            $(function(){
                $("form").submit(function(){                
                    $.post('/auth/login', {
                        admin    : $(".admin").val(),
                        password : $(".password").val(),
                        submit   : 1
                    }, function(data) {
                        data = $.trim(data);
                        if(data == 'right'){
                            $(".login_mes").text('登陆成功,正在跳转...').removeClass("hide");
                            window.location.href="/";
                        }else{
                            $(".login_mes").text('密码错误').removeClass("hide");
                        }
                    });
                    return false; 
                })
            })
        </script>

        <div class="form-box" id="login-box">
            <div class="header">登陆</div>
            <form action="/auth/login" method="post">
                <div class="body bg-gray">
                    <div class="form-group">
                        <input type="text" name="admin" class="form-control admin" placeholder="用户名"/>
                    </div>
                    <div class="form-group">
                        <input type="password" name="password" class="form-control password" placeholder="密码"/>
                    </div>          
                </div>
                <div class="footer">                                                               
                    <button type="submit" class="btn bg-olive btn-block login_btn">登陆</button>  
                    <p class="login_mes hide"></p>
                </div>
            </form>
        </div>

    </body>
</html>