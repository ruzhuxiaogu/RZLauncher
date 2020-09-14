# RZLauncher

iOS启动框架，支持启动生命周期分发，启动任务分布式注册，启动任务依赖，支持设置启动任务在各生命周期的优先级，执行所在线程以及对其他启动任务的依赖。根据启动任务的依赖关系，检测循环依赖，并发执行，提升启动的效率。同时，统计各启动任务消耗的时间，暴露给外部使用。


## 接入

## 使用指南

### 1.生命周期分发
 
 ```
   typedef NS_ENUM(NSInteger, RZLaunchLife) {
    RZLaunchLife_Load = 0,
    RZLaunchLife_Constructor,
    RZLaunchLife_WillFinishLaunching,
    RZLaunchLife_DidFinishLaunchingBeforeHomeRender,
    RZLaunchLife_DidFinishLaunchingAfterHomeRender,
    RZLaunchLife_TaskAfterLaunching,
    RZLaunchLife_AppInitialization,
    RZLaunchLife_DidBecomeActive,
    RZLaunchLife_WillEnterForeground,
    RZLaunchLife_DidEnterBackground,
    RZLaunchLife_WillResignActive,
    RZLaunchLife_HomePageDidAppear,
    RZLaunchLife_HomePageDidActive,
    RZLaunchLife_Min = RZLaunchLife_Load,
    RZLaunchLife_Max = RZLaunchLife_HomePageDidActive,
};
 
 ``` 
 
 在AppDelegate中的启动回调中触发分发，比如：
  
  ```
 [[RZLauncher sharedLauncher] onTrigger:RZLaunchLife_DidBecomeActive]; 
  ```
  
### 2.启动任务注册


(1)  继承RZAppLaunchBaseTask，添加宏 RZLAUNCH_REGISTER(RZAppLaunchTaskName)。

`RZLAUNCH_REGISTER(RZAppLaunchTaskName) `

(2)  实现RZLaunchProtocol协议。
  
   
   ```
   
/*
* 任务执行之前的操作
* @param life 生命周期
*/
- (void)operateBeforeRunLaunchLife:(NSInteger)life;

/*
 * 指定每个生命周期需要执行的操作
 * @param life 生命周期
 */
- (BOOL)runForLaunchLife:(NSInteger)life;

/*
* 任务执行之后的操作
* @param life 生命周期
*/
- (void)operateAfterRunLaunchLife:(NSInteger)life;

/*
* 获取任务执行的时间
* @param life 生命周期
*/
- (CFAbsoluteTime)getOperateTime;

/*
* 是否立即执行，若为否，会先加入队列，然后执行
* @param life 生命周期
*/
- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life;

@optional

/*
* 指定启动任务的前驱，前驱完成后再执行该任务
* @param life 生命周期
*/
- (NSArray <NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life;

/*
* 指定启动任务的执行优先级
* @param life 生命周期
*/
- (RZLaunchPriority)priorityForLaunchLife:(NSInteger)life;

/*
* 指定实例对象
*/
+ (instancetype)launcher;

/*
* 指定启动任务的执行线程
* @param life 生命周期
*/
- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life;

   
   ```
   
  也可以通过plist注册，支持注册任务和配置任务前驱。
  
  ```
  <dict>
	<key>RZAppLaunchTask6</key>
	<dict>
	    //生命周期的枚举值
		<key>7</key>
		<array>
			<string>RZAppLaunchTask2</string>
		</array>
	</dict>
	<key>RZAppLaunchTask7</key>
	<dict>
		<key>7</key>
		<array>
			<string>RZAppLaunchTask2</string>
		</array>
	</dict>
</dict>
</plist>
  
  ```
  

# RZMediator

iOS中间件，protocol-class映射模式，注册和使用起来简单，实现解耦的目的，搭配RZLauncher使用更佳。

## 使用指南

### 1.新建protocol，继承RZModuleBaseProtocol，并新建类来实现该protocol。

  ```
  
@protocol TestProtocol <RZModuleBaseProtocol>

- (void)test;

@end

@interface TestImpl : NSObject <TestProtocol>

@end
  
  ```


### 2.注册protocol及实现该protocol的类名

  ```
  
RZM_EXPORT_MODULE_PROTOCOL(TestProtocol, TestImpl)
  
  ```

### 3.使用。

  ```
[[RZModuleMediator implObjForProtocol: @protocol(TestProtocol)] test];  
  ```
  
  
  示例：
  
  ```
  
#import "RZModuleMediator.h"

@protocol TestProtocol <RZModuleBaseProtocol>

- (void)test;

@end

@interface TestImpl : NSObject <TestProtocol>

@end


RZM_EXPORT_MODULE_PROTOCOL(TestProtocol, TestImpl)
  
  
  ```
  

  
  
  




