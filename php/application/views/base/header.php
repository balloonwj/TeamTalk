
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>TT开源php管理后台</title>
        <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
        <link href="/ui/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <link href="/ui/css/main.css" rel="stylesheet" type="text/css" />
        <link href="/ui/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <link href="/ui/css/ionicons.min.css" rel="stylesheet" type="text/css" />
        <link href="/ui/css/simplemodal.css" rel="stylesheet" type="text/css" />
        <script src="/ui/js/jquery-1.11.1.min.js"></script>
        <script src="/ui/js/bootstrap.min.js" type="text/javascript"></script>
        <script src="/ui/js/juicer.js" type="text/javascript"></script>
        <script src="/ui/js/simple-modal.js" type="text/javascript"></script>

        <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
          <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
        <![endif]-->
    </head>
    <body class="skin-blue">
        <header class="header">
            <a href="/" class="logo">
                TeamTalk
            </a>
            <!-- Header Navbar: style can be found in header.less -->
            <nav class="navbar navbar-static-top" role="navigation">
                <!-- Sidebar toggle button-->
                <a href="#" class="navbar-btn sidebar-toggle" data-toggle="offcanvas" role="button">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </a>
                <div class="navbar-right">
                    <ul class="nav navbar-nav">
                        <li class="dropdown user user-menu">
                            <a href="/auth/logout">
                                <span>退出</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>
        </header>
        <div class="wrapper row-offcanvas row-offcanvas-left">
            <!-- Left side column. contains the logo and sidebar -->
            <aside class="left-side sidebar-offcanvas">
                <!-- sidebar: style can be found in sidebar.less -->
                <section class="sidebar">
                    <!-- sidebar menu: : style can be found in sidebar.less -->
                    <ul class="sidebar-menu">
                        <li>
                            <a href="/user">
                                <span>用户管理</span>
                            </a>
                        </li>
                        <li>
                            <a href="/depart">
                                <span>组织架构</span>
                            </a>
                        </li>
                        <li>
                            <a href="/group">
                                <span>群组管理</span>
                            </a>
                        </li>
                        <li>
                            <a href="/discovery">
                                <span>系统设置</span>
                            </a>
                        </li>
                    </ul>
                </section>
            </aside>