<aside class="right-side">
    <section class="content-header">
        <h1>
            系统配置
            <small>欢迎来到TeamTalk</small>
        </h1>
        <ol class="breadcrumb">
            <li><a href="/"><i class="fa fa-dashboard"></i> 首页</a></li>
            <li class="active">系统配置</li>
        </ol>
    </section>

    <section class="content">
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Login Server IP</th>
                    <th>Config Server IP</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><input type="text" class="cname" value="<?=$config['cname']?>"></td>
                    <td><input type="text" class="value" value="<?=$config['value']?>"></td>
                </tr>
            </tbody>
        </table>
    </section>

    <script type="text/javascript">
        $(function(){
            $(".cname,.value").blur(function(){
                $.post('/config/edit', {
                    cname: $(".cname").val(),
                    value: $(".value").val()
                }, function(data) {
                    if($.trim(data) == 'success'){
                        $(".table").before('<div class="alert alert-success alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>编辑成功</div>')
                    }
                });
            })
        })
    </script>
</aside>