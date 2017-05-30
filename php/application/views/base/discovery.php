<aside class="right-side">
    <section class="content-header">
        <h1>
            发现管理
        </h1>
        <ol class="breadcrumb">
            <li><a href="/"><i class="fa fa-dashboard"></i> 首页</a></li>
            <li class="active">发现管理</li>
        </ol>
    </section>
    <section class="content">
        <button style="margin-bottom:10px;" class="btn btn-primary btn-sm add_discovery pull-right">新增</button>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>标题</th>
                    <th>url</th>
                    <th>优先级</th>
                    <th>编辑</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </section>
    <script type="text/javascript">
        var Discovery = {
            compiledTpl : null,
            compiledAddTpl : null,
            getDiscovery : function(){
                $.getJSON('/discovery/all', {
                }, function(data) {
                    Discovery.tpl();
                    console.log(data);
                    var _tpl = Discovery.compiledTpl.render(data);
                    $("tbody").html(_tpl);
                });
            },
            addTpl : function(){
                var tpl =[
                    '<div class="add_discovery_div" role="form">',
                    '   <input type="text" class="form-control input-sm itemName" placeholder="标题">',
                    '   <input type="text" class="form-control input-sm itemUrl" placeholder="url">',
                    '   <input type="text" class="form-control input-sm itemPriority" placeholder="优先级">',
                    '</div>'
                ].join('\n');
                Discovery.compiledAddTpl = juicer(tpl);
            },
            tpl : function(){
                var tpl=[
                    '{@each discoverys as discovery}',
                    '   <tr data-id="${discovery.id}">',
                    '       <td>${discovery.id}</td>',
                    '       <td>${discovery.itemName}</td>',
                    '       <td>${discovery.itemUrl}</td>',
                    '       <td>${discovery.itemPriority}</td>',
                    '       <td><button style="margin-right:10px;" class="btn btn-warning btn-sm edit_discovery">编辑</button><button href="javascript:;" class="btn btn-danger btn-sm del_discovery">删除</button></td>',
                    '   </tr>',
                    '{@/each}'
                ].join('\n');
                Discovery.compiledTpl = juicer(tpl);
            },
            addDiscoveryAlert : function(){
                Discovery.addTpl();
                $.fn.SimpleModal({
                    btn_ok: '添加',
                    model: 'confirm',
                    callback: function(node){
                        Discovery.addDiscovery();
                    },
                    overlayClick: false,
                    width: 660,
                    title: '添加用户',
                    contents: Discovery.compiledAddTpl.render()
                }).showModal();
            },
            editDiscovery : function(){
                $.post('/discovery/edit', {
                    id:$(".btn-margin-edit").data('id'),
                    itemName: $(".itemName").val(),
                    itemUrl: $(".itemUrl").val(),
                    itemPriority: $(".itemPriority").val()
                }, function(data) {
                    if($.trim(data) == 'success'){
                        $.fn.hideModal();
                        $(".table").before('<div class="alert alert-success alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>编辑成功</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                        User.getUser();
                    }else{
                        $(".btn-margin-edit").text('编辑失败');
                    }
                });
            },
            addDiscovery : function(){
                $.post('/discovery/add', {
                    itemName: $(".itemName").val(),
                    itemUrl: $(".itemUrl").val(),
                    itemPriority: $(".itemPriority").val()
                }, function(data) {
                    if($.trim(data) == 'success'){
                        $.fn.hideModal();
                        $(".table").before('<div class="alert alert-success alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>添加成功</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                    }else{
                        $(".btn-margin").text('添加失败');
                    }
                });
            },
            editiscoveryAlert : function(node){
                Discovery.addTpl();
                $.fn.SimpleModal({
                    btn_ok: '编辑',
                    model: 'confirm',
                    callback: function(node){
                        Discovery.editDiscovery();
                    },
                    overlayClick: false,
                    width: 660,
                    title: '编辑用户',
                    contents: Discovery.compiledAddTpl.render()
                }).showModal();
                $.post('/discovery/get', {
                    id:node.data('id')
                }, function(data) {
                    var data = JSON.parse(data);
                    $(".itemName").val(data.itemName);
                    $(".itemUrl").val(data.itemUrl);
                    $(".itemPriority").val(data.itemPriority);
                    $(".btn-margin").addClass("btn-margin-edit");
                    $(".btn-margin-edit").data('id',node.data('id'));
                });
            }
        }
        $(function(){
            Discovery.getDiscovery();

            $(".add_discovery").click(function(){
                Discovery.addDiscoveryAlert();
            })

            $(".edit_discovery").live("click",function(){
                Discovery.editiscoveryAlert($(this).parents('tr'));
            })

            $(".del_discovery").live("click",function(){
                var node = $(this).parents('tr')
                $.post('/discovery/del', {id: node.data('id')}, function(data) {
                    if($.trim(data) == 'success'){
                        node.fadeOut();
                    }
                });
            })
        })
    </script>
    <style>
        .add_discovery_div input{ 
            margin-top: 20px;
        }
    </style>
</aside>    