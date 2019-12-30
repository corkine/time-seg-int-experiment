# 时间整合与分离

实验代码库。下载代码直接点击`代码文件列表`上面最右边的`下载`按钮。点击`提交历史`查看项目更新历史。关于 MATLAB 和 PTB 开发环境配置，参见 [帮助中心](http://help.mazhangjing.com/matlab_ptb)

## 实验逻辑

> 因为 MATLAB 是动态语言，且没有完善的包管理机制，因此较难分离变量作用域和重构代码。但是因为 MATLAB 函数基于值传递，因此划分函数可以较好的隔离程序各部分状态。为了便于更多人重用，使用脚本代码和函数，而不使用类进行代码的组织和管理。

configLoad.m 函数提供了一些基本配置逻辑，其被主脚本 main.m 加载，main.m 进行一些初始化的配置，比如打开 PTB Window，生成图片刺激，写入数据，之后执行 runXXX.m 主程序，之后清理数据，关闭 Window 句柄。程序逻辑在 runXXX.m 中提供，这样 configLoad 和 main 就可以做到部分的重用。

基于值传递，所以在脚本中的代码如果传入 Struct，必须传出，如果有更改的话。这样避免了状态的混乱。程序主要将参数和数据写在了 SCR、EXP、CONF 这些 Struct 中，在调用函数时，如果更改了 Struct，记得将其返回更新工作区的对应 Struct。

## 图片刺激

图片刺激生成较为复杂，因此使用 Scala 写好，打包之后放在 Psy4J.jar 文件中。得益于 Matlab 2018 之后自带的 Java 虚拟机（版本 8），因此可以直接在 MATLAB 中调用 Java 类，传入和接受参数。生成图片的逻辑封装在 com.mazhangjing.time.MATLABHelper 类中，在 MATLAB 中，其封装在 initPics.m 同名函数中。

当非 Debug 模式时（main 从 configLoad 中获取是否 debug 模式），main.m 会调用 pics/xxx/data.mat 文件获取刺激图片和其元数据，生成刺激。

对于每个被试，使用一个 pics/xxx 文件夹，文件夹中包含了图片和元数据 MAT 文件。使用 initPics 函数打开 JavaFx GUI 生成刺激，其会生成随机的 xxx 文件夹，然后将元数据保存在 xxx/data.mat 中，main.m 函数会自动通过 CONF 确定被试文件夹，并且通过读取元数据抓取图片加载刺激。

注意，因为 MATLAB 窗口本身就是 JavaFx 程序，因此不能在一个 MATLAB 实例中多次打开 JavaFx 实例。所以，当在一个 MATLAB 实例中调用 initPics 后，必须关闭 MATLAB，才能重新调用。

![](http://static2.mazhangjing.com/20191204/ff661f0_WX20191204-181236.png)

> Psy4J.jar 只能运行在 Java 8 版本中，其文件较大，是因为封装了 Scala 类库所致（16 MB）。

> 默认生成好了一套刺激供 Debug 使用：pics/1779，其文件名在 configLoad 中配置，在 debug 模式或者不指定 picId 情况下，默认使用这些刺激图片和元信息。

> 生成图片和元信息供被试使用，只需要运行 initPics 命令，然后生成即可，注意，在运行之前重写 configLoad.m 中 CONF.debug 为你需要的值，一般设置为 false 可满足大多数使用。

> 调用 main.m 的时候，设置 configLoad 中的 debug 为 false，然后在对话框中输入 picsId 即可为被试使用此刺激。

## 结果说明

数据保存在 `姓名@日期.mat` 文件中。如下所示：

![](http://static2.mazhangjing.com/20191206/cc9d42a_data_example.png)

DATA struct 包含 segData、intData 信息，这是主要的数据，此外还有被试实验的 scrInfo - SCR struct 以及 conf - CONF struct 额外配置信息。

segData 对应分离的 DATA struct，intData 对应整合的 DATA struct。其中，data 标示了所有刺激（不管用到还是没用到的）的信息，比如内含的判断的点的个数（负数表示），图片标号（用于对应图片文件），以及图片整合后的阵列信息（方便判断对错）。isSeg 标示是否是分离数据，isLearn 标示是否是学习数据，segStartTime 标示数据收集开始的时间，pictures 标示刺激的图片文件（不一定全部使用），isiWithRepeat 标示 trials 对应的 isi，answers 标示 trials 对应的被试的回答是否正确，actionTime 标示 trials 对应的反应时（单位为秒，从最后一帧消失开始计时），usedData 标示 trials 使用到的 data 部分。


## 最佳实践

1. 对于函数写详细的注释，包括函数的作用和参数的作用。
2. 对于函数参数使用 struct 而不是过长的参数列表。
3. 对于更改了 struct，要及时的说明和备注，以方便追踪在何处更改了什么字段。
4. 默认值使用位于一个地方。
5. 使用 assert 进行条件的判断，及时抛出错误。
6. 不要使用全局变量，尽量不要在作用域内暴露无关的变量。
7. 在脚本中使用分号;

## 主试注意事项

1. 要求被试在做任务的时候区分刺激是三角还是方块，并且暗示这两者没有关系，防止被试意识到在 prefISI 阶段三角个数意味着方块个数。
2. 当输入错误的时候，按下 back 即可删除，当输入完毕的时候，按下 enter 即可提交。
3. 告诉被试全程计算正确率，最终报酬和正确率有关。

## 程序测试规范

1. 测试 main > initConditionWithTry 是否工作正常，正确率是否计算正常
	- 在某些情况下不通过基准正确率查看是否可重复触发练习
	- 在某些情况下完全通过，查看正确率是否计算正确
2. 测试 main > initCondition 是否输出正确的数据
	- 包含数据 k 是否没有嵌套（需完整走一遍 debug 测试）
	- 包含是否数据完全输出没有报错（需完整走一遍 debug 模式）