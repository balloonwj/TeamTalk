<aside class="right-side">
    <section class="content-header">
        <h1>
            组织架构管理
            <small>欢迎来到TeamTalk</small>
        </h1>
        <ol class="breadcrumb">
            <li><a href="/"><i class="fa fa-dashboard"></i> 首页</a></li>
            <li class="active">组织架构</li>
        </ol>
    </section>
    <section class="content">
        <button style="margin-bottom:10px;" class="btn btn-primary btn-sm add_depart pull-right">新增</button>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>部门名称</th>
                    <th>部门优先级</th>
                    <th>父部门</th>
                    <th>编辑</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </section>
    <script>
        var Depart = {
            compiledTpl : null,
            compiledAddTpl : null,
            getDepart : function(page){
                $.getJSON('/depart/all', function(data) {
                    var pdeparts = [];
                    for(i in data.departs){
                        if(data.departs[i].parentId == 0){
                            pdeparts.push(data.departs[i]);
                        }
                    }
                    $("table").data('depart',data);
                    $("table").data('pdepart',pdeparts);
                    Depart.tpl();
                    var _tpl = Depart.compiledTpl.render(data);
                    $("tbody").html(_tpl);
                });
            },
            delDepart : function(node){
                $.post('/depart/del', {id: node.data('id')}, function(data) {
                    if($.trim(data) == 'has departs'){
                        $(".add_depart").before('<div class="alert alert-danger alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>当前部门还有子部门</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                    }
                    if($.trim(data) == 'has users'){
                        $(".add_depart").before('<div class="alert alert-danger alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>当前部门下有用户</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                    }
                    if($.trim(data) == 'success'){
                        node.fadeOut();
                    }
                });
            },
            addDepartAlert : function(){
                Depart.addTpl();
                $.fn.SimpleModal({
                    btn_ok: '添加',
                    model: 'confirm',
                    callback: function(node){
                        Depart.addDepart();
                    },
                    overlayClick: false,
                    width: 660,
                    departName: '添加部门',
                    contents: Depart.compiledAddTpl.render({departs:$("table").data('pdepart')})
                }).showModal();
            },
            editDepartAlert : function(node){
                Depart.addTpl();
                $.fn.SimpleModal({
                    btn_ok: '编辑',
                    model: 'confirm',
                    callback: function(node){
                        Depart.editDepart();
                    },
                    overlayClick: false,
                    width: 660,
                    departName: '编辑用户',
                    contents: Depart.compiledAddTpl.render({departs:$("table").data('pdepart')})
                }).showModal();
                $.post('/depart/get', {
                    id:node.data('id')
                }, function(data) {
                    var data = JSON.parse(data);
                    $(".departName").val(data.departName);
                    $(".priority").val(data.priority);
                    $(".parentId").val(data.parentId);
                    if(data.parentId == 0){
                        $(".parentId").attr("disabled","disabled");
                    }else{
                        $($(".parentId option")[0]).attr("disabled","disabled");
                    }
                    $(".btn-margin").addClass("btn-margin-edit");
                    $(".btn-margin-edit").data('id',node.data('id'));
                });
            },
            editDepart : function(){
                $.post('/depart/edit', {
                    departName: $(".departName").val(),
                    priority: $(".priority").val(),
                    parentId: $(".parentId").val(),
                    id:$(".btn-margin-edit").data('id')
                }, function(data) {
                    if($.trim(data) == 'success'){
                        $.fn.hideModal();
                        $(".add_depart").before('<div class="alert alert-success alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>编辑成功</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                        Depart.getDepart();
                    }else{
                        $(".btn-margin-edit").text('编辑失败');
                    }
                });
            },
            addDepart : function(){
                $.post('/depart/add', {
                    departName: $(".departName").val(),
                    priority: $(".priority").val(),
                    parentId: $(".parentId").val()
                }, function(data) {
                    if($.trim(data) == 'success'){
                        $.fn.hideModal();
                        $(".add_depart").before('<div class="alert alert-success alert-dismissable"><i class="fa fa-check"></i><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>添加成功</div>')
                        setTimeout(function(){
                            $(".alert").remove();
                        },3000);
                        Depart.getDepart();
                    }else{
                        $(".btn-depart").text('添加失败');
                    }
                });
            },
            addTpl : function(){
                var tpl =[
                    '<div class="add_depart_div" role="form">',
                    '   <input type="text" class="form-control input-sm departName" placeholder="部门名称">',
                    '   <input type="number" class="form-control input-sm priority" placeholder="部门优先级">',
                    '   <select class="form-control parentId" >',
                    '       <option value="0">父部门</option>',
                    '           {@each departs as depart}',
                    '               <option value="${depart.id}">${depart.departName}</option>',
                    '           {@/each}',
                    '   </select>',
                    '</div>'
                ].join('\n');
                Depart.compiledAddTpl = juicer(tpl);
            },
            tpl : function(){
                var tpl=[
                    '{@each departs as depart}',
                    '   <tr data-id="${depart.id}">',
                    '       <td>${depart.id}</td>',
                    '       <td>${depart.departName}</td>',
                    '       <td>${depart.priority}</td>',
                    '       <td>${depart.parentId_value}</td>',
                    '       <td><button style="margin-right:10px;" class="btn btn-warning btn-sm edit_depart">编辑</button><button href="javascript:;" class="btn btn-danger btn-sm del_depart">删除</button></td>',
                    '   </tr>',
                    '{@/each}'
                ].join('\n');
                Depart.compiledTpl = juicer(tpl);
            }
        }
        $(function(){
            Depart.getDepart();

            $(".del_depart").live("click",function(){
                Depart.delDepart($(this).parents('tr'));
            })

            $(".add_depart").click(function(){
                Depart.addDepartAlert();
            })

            $(".edit_depart").live("click",function(){
                Depart.editDepartAlert($(this).parents('tr'));
            })
        })
    </script>
    <style>
        .add_depart_div input,.add_depart_div select{
            width: 620px;
            margin-top: 20px;
        }
    </style>
</aside>