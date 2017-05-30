package com.mogujie.tt.imservice.manager;

import android.content.Context;

/**
 * V3
 * 自身状态有些不是互斥的
 * 事件可以是多种的，触发的事件与自身的状态是两码事
 * 有些manager只能是单个的，例如socket 登陆
 * 但有些可能是多个，group 【正规群，临时群都ok】
 *
 * 程序默认使用EventBus做为总线
 */
public abstract class IMManager {
	protected Context ctx;
    protected void setContext(Context context) {
		if (context == null) {
			throw new RuntimeException("context is null");
		}
		ctx = context;
	}

    public void  onStartIMManager(Context ctx){
        setContext(ctx);
        doOnStart();
    }
    /**
     * imService 服务建立的时候
     * 初始化所有的manager 调用onStartIMManager会调用下面的方法
     */
    public abstract  void doOnStart();
    /**
     * 上下文环境的更新
     * 1. 环境变量的clear
     * 2. eventBus的清空
     * */
	public abstract void reset();
}
