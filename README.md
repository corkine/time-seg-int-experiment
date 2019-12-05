# 时间整合与分离

实验代码库。下载代码直接点击`代码文件列表`上面最右边的`下载`按钮。点击`提交历史`查看项目更新历史。关于 MATLAB 和 PTB 开发环境配置，参见 [帮助中心](http://help.mazhangjing.com/matlab_ptb)

## 实验逻辑

> 因为 MATLAB 是动态语言，且没有完善的包管理机制，因此较难分离变量作用域和重构代码。但是因为 MATLAB 函数基于值传递，因此划分函数可以较好的隔离程序各部分状态。为了便于初学者重用，使用脚本代码和函数，而不使用类进行代码的组织和管理。

configLoad.m 函数提供了一些基本配置逻辑，其被主脚本 main.m 加载，main.m 进行一些初始化的配置，比如打开 PTB Window，生成图片刺激，写入数据，之后执行 runXXX.m 主程序，之后清理数据，关闭 Window 句柄。程序逻辑在 runXXX.m 中提供，这样 configLoad 和 main 就可以做到部分的重用。

基于值传递，所以在脚本中的代码如果传入 Struct，必须传出，如果有更改的话。这样避免了状态的混乱。程序主要将参数和数据写在了 SCR、EXP、CONF 这些 Struct 中，在调用函数时，如果更改了 Struct，记得将其返回更新工作区的对应 Struct。

## 图片刺激

图片刺激生成较为复杂，因此使用 Scala 写好，打包之后放在 Psy4J.jar 文件中。得益于 Matlab 2018 之后自带的 Java 虚拟机（版本 8），因此可以直接在 MATLAB 中调用 Java 类，传入和接受参数。生成图片的逻辑封装在 com.mazhangjing.time.MATLABHelper 类中，在 MATLAB 中，其封装在 initPics.m 同名函数中。

当非 Debug 模式时（main 从 configLoad 中获取是否 debug 模式），main.m 会调用 initPics.m 打开 JavaFx GUI，生成刺激。GUI 的默认参数可以通过 initPics 参数传入，点击生成即可。注意，因为 MATLAB 窗口本身就是 JavaFx 程序，因此不能在一个 MATLAB 实例中多次打开 JavaFx 实例。所以，当在一个 MATLAB 实例中调用 initPics 后，必须关闭 MATLAB，才能重新调用。

![](http://static2.mazhangjing.com/20191204/ff661f0_WX20191204-181236.png)

> Psy4J.jar 只能运行在 Java 8 版本中，其文件较大，是因为封装了 Scala 类库所致（16 MB）。

## 最佳实验

1. 对于函数写详细的注释，包括函数的作用和参数的作用。
2. 对于函数参数使用 struct 而不是过长的参数列表。
3. 对于更改了 struct，要及时的说明和备注，以方便追踪在何处更改了什么字段。
4. 默认值使用位于一个地方。
5. 使用 assert 进行条件的判断，及时抛出错误。
6. 不要使用全局变量，尽量不要在作用域内暴露无关的变量。
