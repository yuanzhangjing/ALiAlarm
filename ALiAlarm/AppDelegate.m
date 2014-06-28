//
//  AppDelegate.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "AppDelegate.h"
#import "NSDate+convenience.h"
#import "AudioToolbox/AudioToolbox.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LocalNotification.h"
#define DayToIntervals 24*3600
#define Tag_alert_normal_1 1001
#define Tag_alert_normal_2 1002
#define Tag_alert_normal_3 1003
#define Tag_alert_normal_4 1004

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize navigationController = _navigationController;
@synthesize homeVC = _homeVC;
@synthesize player = _player;

@synthesize backgroundtaskidentifer = _backgroundtaskidentifer;
@synthesize backgroundTimer=_backgroundTimer;
-(void)setDefaultData{
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; //清空本地通知
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [USER_DEFAULT setObject:[NSNumber numberWithBool:YES] forKey:HAVE_BEEN_USED];
    [USER_DEFAULT setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:SYSTEM_SHORT_VERSION] forKey:LASTVERSION];
    NSArray *array = [NSArray arrayWithObjects:@"梦幻",@"欢乐颂",@"Piano",@"Yellow",@"Let it go",@"命运交响曲",@"we are the world",nil];
    [USER_DEFAULT setObject:array forKey:RINGS];
    [USER_DEFAULT synchronize];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![USER_DEFAULT boolForKey:HAVE_BEEN_USED]) {
        NSLog(@"软件第一次使用！");
        [self setDefaultData];
        //add some operations

    }
    NSString *lastVersion = [USER_DEFAULT stringForKey:LASTVERSION];
    NSString *currentVersion =[[[NSBundle mainBundle] infoDictionary] objectForKey:SYSTEM_SHORT_VERSION];
    NSLog(@"lastversion:%@ currentversion:%@",lastVersion,currentVersion);
    NSComparisonResult result = [lastVersion compare:currentVersion];
    
    if (result == NSOrderedAscending) { //更新版本第一次使用 处理
        NSLog(@"该版本第一次使用！");
        [USER_DEFAULT setObject:currentVersion forKey:LASTVERSION];
        [USER_DEFAULT synchronize];
        //add some operations

    }

    UILocalNotification *notification=[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(notification!=nil){
        NSDictionary *dic = [notification userInfo];
        NSString *beanIdentifer = [dic objectForKey:@"Identifer"];
        if (beanIdentifer.length==0) {
            beanIdentifer = [dic objectForKey:@"NapIdentifer"];
        }
        _receivedBean = [myCoreData queryDataBean:beanIdentifer];
        _seq = [[notification.userInfo objectForKey:@"Sequence"] intValue];
        _notiFireDate = notification.fireDate;
        [self processLocalNotification];
    }else{
        if (application.applicationIconBadgeNumber==1) {
            //没有从通知栏进入 判断最近是否有闹钟响起 找到距离现在最近的一个响过的本地通知！
//            NSArray *array = [myCoreData queryAllOpenDataBeans];
//            int min = INT_MAX;
//            DataBean *_bean;
//            for (int i = 0; i<array.count; i++) {
//                DataBean *bean = [array objectAtIndex:i];
//                NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:bean.nextFiretime];
//                if (t>0&&t<min) {
//                    _bean = bean; //找到距离现在提醒时间最近的bean（已经提醒过了）
//                }
//            }
            DataBean *_bean =[self getTheLastFireBean];
            if (_bean) {
                _receivedBean = _bean;
                _seq = -2;
                _notiFireDate = _bean.nextFiretime;
                [self processLocalNotification];
            }
            for (DataBean *d in [myCoreData queryAllOpenDataBeans]) {
                if (d.alarmDays.unsignedIntegerValue==0&&![d.identifer isEqualToString:_bean.identifer]) {
                    if ([d.nextFiretime compare:[NSDate date]]==NSOrderedAscending) {
                        d.alarmState = [NSNumber numberWithBool:NO];
                        [myCoreData updateDataBean:d];
                    }
                }
            }
            
                /*
                if (bean.alarmDays.unsignedIntegerValue==0) {
                    if ([bean.fireDate compareWithHHmm:bean.updateTime]==NSOrderedAscending) {
                        bean.fireDate=[bean.fireDate setToDate:[bean.updateTime setToNextDay]];
                    }else{
                        bean.fireDate=[bean.fireDate setToDate:bean.updateTime];
                    } //此时的fireDate为真实提醒的时间
                    if ([bean.fireDate compare:[NSDate date]]==NSOrderedAscending) {
                        //说明时间过了 这里为了统一模拟一个本地通知 处理当前事件
                        UILocalNotification *ln = [self checkLeftLocalNotification:bean];
                        if (ln) {
                            [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
                        }else{
                            UILocalNotification *ln = [[UILocalNotification alloc] init];
                            ln.fireDate = bean.fireDate;
                            NSMutableDictionary *userDic =[[NSMutableDictionary alloc] initWithCapacity:2];
                            [userDic setObject:bean.identifer forKey:@"Identifer"];
                            [userDic setObject:[NSNumber numberWithInt:-2] forKey:@"Sequence"];
                            ln.userInfo = userDic;
                            [self processLocalNotification:ln];
                        }
                        break;
                    }
                }else{//判断今天是否有闹钟。
                    int today = [[NSDate date] weekday]; //今天周几
                    if ((bean.alarmDays.unsignedIntegerValue&(1<<(today-1)))>0) { //今天有提醒
                        bean.fireDate = [bean.fireDate setToday]; //今天真实的提醒时间
                        if ([bean.fireDate compare:[NSDate date]]==NSOrderedAscending) {
                            //说明时间过了 这里为了统一模拟一个本地通知 处理当前事件
                            UILocalNotification *ln = [self checkLeftLocalNotification:bean];
                            if (ln) {
                                [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
                            }else{
                                UILocalNotification *ln = [[UILocalNotification alloc] init];
                                ln.fireDate = bean.fireDate;
                                NSMutableDictionary *userDic =[[NSMutableDictionary alloc] initWithCapacity:2];
                                [userDic setObject:bean.identifer forKey:@"Identifer"];
                                [userDic setObject:[NSNumber numberWithInt:-2] forKey:@"Sequence"];
                                ln.userInfo = userDic;
                                [self processLocalNotification:ln];
                            }
                            break;
                        }
                    }else{
                        //今天没有提醒 不做处理
                    }
                }*/
            
        }
        NSLog(@"当前%d个通知已经注册！！！",[application scheduledLocalNotifications].count);
    }
    [self registerAllLocalNotificationsWithoutNap];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //change the color of statusbar
    if (IOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    // Override point for customization after application launch.
    _homeVC = [[HomeViewController alloc] init];
    _navigationController = [[MyNavigationViewController alloc] initWithRootViewController:_homeVC];

    self.window.rootViewController = _navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}
-(UILocalNotification*)checkLeftLocalNotification:(DataBean*)bean{
    int d = [[NSDate date] weekday];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
        for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([ln.fireDate weekday]==d&&[[ln.userInfo objectForKey:@"Identifer"] isEqualToString:bean.identifer]&&[ln.userInfo objectForKey:@"Sequence"]>0) {
            [array addObject:ln];
        }
    }
    if (array.count==0) {
        return nil;
    }else{
        UILocalNotification *ln = [array objectAtIndex:0];
        [array removeObjectAtIndex:0];
        for (int i = 0; i<array.count; i++) {
            [[UIApplication sharedApplication] cancelLocalNotification:[array objectAtIndex:i]];
        }
        return ln;
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [application setApplicationIconBadgeNumber:0];

    [self startBackgroundtask];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _backgroundtaskidentifer =[application beginBackgroundTaskWithExpirationHandler:^(void) {
        
        // 当应用程序留给后台的时间快要到结束时（应用程序留给后台执行的时间是有限的）， 这个Block块将被执行
        // 我们需要在次Block块中执行一些清理工作。
        // 如果清理工作失败了，那么将导致程序挂掉
        
        // 清理工作需要在主线程中用同步的方式来进行
        [self clearFakeTask];
    }];
    
    // 模拟一个Long-Running Task
    _timer_fakeTask =[NSTimer scheduledTimerWithTimeInterval:10.0f
                                                   target:self
                                                 selector:@selector(fakeTaskMethod) userInfo:nil
                                                  repeats:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    /*
    if (_backgroundtaskidentifer != UIBackgroundTaskInvalid){
        
        [self clearBackgroundtask];
    }
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (_backgroundtaskidentifer != UIBackgroundTaskInvalid){
        
        [self clearFakeTask];
    }
    [self clearBackgroundtask];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [self registerAllLocalNotificationsWithNap];
    NSLog(@"当前通知总数为：%d",[[application scheduledLocalNotifications] count]);
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
#pragma mark timeprocess
-(NSDate*)getNextFiretime:(DataBean*)bean{
    if (bean.alarmDays.unsignedIntegerValue==0) {//不重复闹钟
        return [bean.fireDate judgeAndSetToNextDay];
    }else{
        int t = [[NSDate date] weekday];
        int num,d = 0;
        for (num=t; num<=t+7; num++) {
            if ((bean.alarmDays.unsignedIntegerValue&(1<<(num%7-1)))>0) {
                if (num==t) {
                    if ([[bean.fireDate setToday] compare:[NSDate date]]==NSOrderedDescending) {
                        break;
                    }else{
                        continue;
                    }
                }
                break;
            }
        }
        d = num - t;
        return [[bean.fireDate setToday] dateByAddingTimeInterval:d*DayToSec];
    }
}
-(DataBean*)getTheLastFireBean{
    NSArray *array = [myCoreData queryAllOpenDataBeans];
    int min = INT_MAX;
    DataBean *_bean;
    for (int i = 0; i<array.count; i++) {
        DataBean *bean = [array objectAtIndex:i];
        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:bean.nextFiretime];
        if (t>0&&t<min) {
            min = t;
            _bean = bean; //找到距离现在提醒时间最近的bean（已经提醒过了的）
        }
    }
    return _bean;
}
-(DataBean*)getTheNextFireBean{
    NSArray *array = [myCoreData queryAllOpenDataBeans];
    int min = INT_MAX;
    DataBean *_bean;
    for (int i = 0; i<array.count; i++) {
        DataBean *bean = [array objectAtIndex:i];
        NSTimeInterval t = [bean.nextFiretime timeIntervalSinceDate:[NSDate date]];
        if (t>0&&t<min) {
            min = t;
            _bean = bean; //找到距离现在提醒时间最近的bean（还未提醒的）
        }
    }
    return _bean;
}
#pragma mark backgroundtask
-(void)fakeTaskMethod{
    NSLog(@"I'm a fake task! time_remaining=%.2fs",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    if (_backgroundTimer==nil) { //加一层保护 防止有后台任务而后台没有启动
        [self startBackgroundtask];
    }
}
-(void)clearFakeTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^(void) {
            [_timer_fakeTask invalidate];// 停止定时器
            
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundtaskidentifer];
            // 销毁后台任务标识符
            _backgroundtaskidentifer = UIBackgroundTaskInvalid;
    });
}
-(void)startBackgroundtask{
    if ([UIApplication sharedApplication].scheduledLocalNotifications.count>0) {
        [self playSilenceSound];
        if (_backgroundTimer==nil) {
            _backgroundTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
                                                               target:self
                                                             selector:@selector(backgroundTimerMethod) userInfo:nil
                                                              repeats:YES];
        }
        
        NSLog(@"后台任务开启");
    }else{
        [self stopSilenceSound];
        NSLog(@"无任务，不开启后台");
    }
}
-(void)backgroundTimerMethod{
    NSLog(@"I'm still alive!");
    for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
//        NSLog(@"%@ %@",[NSDate date],ln.fireDate);
        NSTimeInterval timeLeft = [ln.fireDate timeIntervalSinceDate:[NSDate date]];
        if (timeLeft<=1&&timeLeft>0) {
            _ProcessFlag = YES;
            NSDictionary *dic = [ln userInfo];
            NSString *beanIdentifer = [dic objectForKey:@"Identifer"];
            if (beanIdentifer.length==0) {
                beanIdentifer = [dic objectForKey:@"NapIdentifer"];
            }
            _receivedBean = [myCoreData queryDataBean:beanIdentifer];
            _seq = [[ln.userInfo objectForKey:@"Sequence"] intValue];
            _notiFireDate = ln.fireDate;

            [self performSelector:@selector(processLocalNotification) withObject:nil afterDelay:1.2f];
        }
    }
}
-(void)clearBackgroundtask{
        [self stopSilenceSound];
        [_backgroundTimer invalidate];
        _backgroundTimer = nil;
    NSLog(@"后台任务结束");
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ALiAlarm" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ALiAlarm.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark - LocalNotificationDelegate
-(void)receiveNormalAlarm:(DataBean*)bean{
    UIApplication *application = [UIApplication sharedApplication];
    switch (application.applicationState) {
        case UIApplicationStateActive:{
            if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
                [self playSound];
            }
            if ((bean.ringType.unsignedIntegerValue&RingTypeVibrate)>0) {
                [self startVibrate];
            }
            if (bean.napTime.unsignedIntegerValue==0) { //没有小睡
                if (bean.alarmDays.unsignedIntegerValue==0) { //不重复闹钟直接关闭
                    bean.alarmState = [NSNumber numberWithBool:NO];
//                    [myCoreData updateDataBean:bean];
                }
                UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了" message:@"active"
                                                                 delegate:self cancelButtonTitle:@"不再提醒" otherButtonTitles:nil];
                alertview.tag = Tag_alert_normal_1;
                [alertview show];
            }else{ //有小睡  将通知延后一天或是一周 并提示
                /*
                if (bean.alarmDays.unsignedIntegerValue==0) { //有小睡的不重复闹钟 只取消不注册 点击停止后关闭
                    [self cancleLocalNotifications:_receivedBean];
                }else{
                    [self cancleLocalNotifications:_receivedBean];
                    [self registerNormalAlarm:_receivedBean];
                }*/
                UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了" message:@"active"
                                                                 delegate:self cancelButtonTitle:@"稍后提醒" otherButtonTitles:@"不再提醒", nil];
                alertview.tag = Tag_alert_normal_2;
                [alertview show];
            }
        }
            break;
        case UIApplicationStateInactive:{
            //下面判断一下从通知进入的时间和到提醒时间的差值
                if (bean.napTime.unsignedIntegerValue==0) { //没有小睡
                    if (bean.alarmDays.unsignedIntegerValue==0) { //不重复闹钟直接关闭
                        bean.alarmState = [NSNumber numberWithBool:NO];
//                        [myCoreData updateDataBean:bean];
                    }
                    if ([[NSDate date] timeIntervalSinceDate:_notiFireDate]<=60) {
                        if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
                            [self playSound];
                        }
                        if ((bean.ringType.unsignedIntegerValue&RingTypeVibrate)>0) {
                            [self startVibrate];
                        }
                        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了！" message:@"inactive"
                                                                         delegate:self cancelButtonTitle:@"不再提醒" otherButtonTitles:nil];
                        alertview.tag = Tag_alert_normal_3;
                        [alertview show];
                    }else{
                        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟已经提醒过了哟！" message:@"inactive"
                                                                         delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertview show];
                    }
                }else{ //有小睡
                    if ([[NSDate date] timeIntervalSinceDate:_notiFireDate]<=60) {
                        if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
                            [self playSound];
                        }
                        if ((bean.ringType.unsignedIntegerValue&RingTypeVibrate)>0) {
                            [self startVibrate];
                        }
                        /*
                        if (bean.alarmDays.unsignedIntegerValue==0) { //有小睡的不重复闹钟 只取消不注册 点击停止后关闭
                            [self cancleLocalNotifications:_receivedBean];
                        }else{
                            [self cancleLocalNotifications:_receivedBean];
                            [self registerNormalAlarm:_receivedBean];
                        }*/
                        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了！" message:@"inactive"
                                                                         delegate:self cancelButtonTitle:@"稍后提醒" otherButtonTitles:@"不再提醒", nil];
                        alertview.tag = Tag_alert_normal_4;
                        [alertview show];
                    }else{
                        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟已经提醒过了哟！" message:@"inactive"
                                                                         delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertview show];
                    }
                }

        }
            break;
        case UIApplicationStateBackground:{
            if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
                [self playSound];
            }
            if ((bean.ringType.unsignedIntegerValue&RingTypeVibrate)>0) {
                [self startVibrate];
            }
            if (bean.napTime.unsignedIntegerValue==0) { //没有小睡
                if (bean.alarmDays.unsignedIntegerValue==0) { //不重复闹钟直接关闭
                    bean.alarmState = [NSNumber numberWithBool:NO];
//                    [myCoreData updateDataBean:bean];
                }
                UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了" message:@"background"
                                                                 delegate:self cancelButtonTitle:@"不再提醒" otherButtonTitles:nil];
                alertview.tag = Tag_alert_normal_1;
                [alertview show];
            }else{ //有小睡
                /*
                if (bean.alarmDays.unsignedIntegerValue==0) { //有小睡的不重复闹钟 只取消不注册 点击停止后关闭
                    [self cancleLocalNotifications:_receivedBean];
                }else{
                    [self cancleLocalNotifications:_receivedBean];
                    [self registerNormalAlarm:_receivedBean];
                }*/
                UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"阿狸闹钟提醒您，闹铃响了" message:@"background"
                                                                 delegate:self cancelButtonTitle:@"稍后提醒" otherButtonTitles:@"不再提醒", nil];
                alertview.tag = Tag_alert_normal_2;
                [alertview show];
            }
        }
            break;
        default:
            break;
    }
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    receivedBean = [[DataBean alloc] init];
//    receivedBean.alarmType = [dic objectForKey:@"AlarmType"];
//    receivedBean.fireDate = [dic objectForKey:@"FireDate"];
//    receivedBean.identifer = [dic objectForKey:@"Identifer"];
//    receivedBean.alarmDays = [dic objectForKey:@"AlarmDays"];
//    receivedBean.napTime = [dic objectForKey:@"NapTime"];
//    receivedBean.alarmState = [dic objectForKey:@"AlarmState"];
//    receivedBean.alarmLabel = [dic objectForKey:@"AlarmLabel"];
//    receivedBean.ringType = [dic objectForKey:@"RingType"];
//    receivedBean.soundName = [dic objectForKey:@"SoundName"];
//    receivedBean.soundVolume = [dic objectForKey:@"SoundVolume"];
//    receivedBean.updateTime = [dic objectForKey:@"UpdateTime"];
//    receivedBean.weiboContent = [dic objectForKey:@"WeiboContent"];
    
//    _notificationIdentifer = [dic objectForKey:@"NotificationIdentifer"];
    NSDictionary *dic = [notification userInfo];
    NSString *beanIdentifer = [dic objectForKey:@"Identifer"];
    if (beanIdentifer.length==0) {
        beanIdentifer = [dic objectForKey:@"NapIdentifer"];
    }
    _receivedBean = [myCoreData queryDataBean:beanIdentifer];
    _seq = [[notification.userInfo objectForKey:@"Sequence"] intValue];
    _notiFireDate = notification.fireDate;

    if (application.applicationState == UIApplicationStateActive) {
        [self processLocalNotification];
    }else if(application.applicationState == UIApplicationStateInactive && _ProcessFlag == NO){
        _ProcessFlag = YES;
        [self processLocalNotification];
    }
    
//    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    for (UILocalNotification *l in array) {
//        NSLog(@"%@",l);
//    }
}
-(void)processLocalNotification{
        switch (_receivedBean.alarmType.unsignedIntegerValue) {
        case AlarmTypeDefault:{
            [self receiveNormalAlarm:_receivedBean];
        }
            break;
        case AlarmTypeReminder:{
        }
            break;
        case AlarmTypeCountDown:{
        }
            break;
        case AlarmTypeAbnormal:{
        }
            break;
            
        default:
            break;
    }
    //remove all the notifications in the ban

}
#pragma mark - Audio
-(void)playSilenceSound{
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    AudioSessionInitialize(NULL, NULL, interruptionListenner, (__bridge void*)self);

    
        {
            NSString * path = [[NSBundle mainBundle] pathForResource:@"Piano" ofType:@"caf"];
            //该方法 返回 主束文件夹下 “莫斯科没有眼泪.mp3” 文件的路径字符串，如果没有该文件的话，返回null。
            
            //NSLog(@"music file path:%@",path);
            
            if(path!=nil){
                NSURL * url = [NSURL fileURLWithPath:path];
                audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];//实例化 一个player 并指定其播放的歌曲。
                audioplayer.numberOfLoops=-1;//设置循环播放的次数： -1 代表 一直循环播放！
                [audioplayer prepareToPlay];
                [audioplayer setVolume:0];
                [audioplayer play];
            };//如果 没有音乐问文件，则直接退出，否者执行下面代码 回出问题。
        }
}
void interruptionListenner(void* inClientData, UInt32 inInterruptionState)
{
    AppDelegate* pTHIS = (__bridge AppDelegate*)inClientData;
    if (pTHIS) {
        if (kAudioSessionBeginInterruption == inInterruptionState) {
            printf("\nBegin interruption\n");
            [pTHIS clearBackgroundtask];
        }
        else
        {
            printf("\nBegin end interruption\n");
            [pTHIS startBackgroundtask];
            printf("\nEnd end interruption\n");
        }
        
    }
}

-(void)stopSilenceSound{
    if (audioplayer.playing) {
        [audioplayer stop];
        audioplayer = nil;
    }
}
/*
void interruptionListenner(void* inClientData, UInt32 inInterruptionState)
{
    AppDelegate* pTHIS = (__bridge AppDelegate*)inClientData;
    if (pTHIS) {
        printf("interruptionListenner %lu", inInterruptionState);
        if (kAudioSessionBeginInterruption == inInterruptionState) {
            printf("Begin interruption");
        }
        else
        {
            printf("Begin end interruption");
            printf("End end interruption");
        }
        
    }
}*/
-(void)playSound{
    if(!_player){ // 如果没有定义 player实例，则 定义新的 player 实例。
        NSString * path = [[NSBundle mainBundle] pathForResource:_receivedBean.soundName ofType:@"caf"];
        //该方法 返回 主束文件夹下 “莫斯科没有眼泪.mp3” 文件的路径字符串，如果没有该文件的话，返回null。
        
        //NSLog(@"music file path:%@",path);
        
        if(path==nil)return;//如果 没有音乐问文件，则直接退出，否者执行下面代码 回出问题。
        
        [self setApplicationVolume:_receivedBean.soundVolume.floatValue];

        NSURL * url = [NSURL fileURLWithPath:path];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];//实例化 一个player 并指定其播放的歌曲。
        _player.numberOfLoops=-1;//设置循环播放的次数： -1 代表 一直循环播放！
        _player.volume=0.4;
        if (_timer_volume==nil) {
            _timer_volume = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setPlayerVolume) userInfo:nil repeats:YES];
        }
        
    }
    
    if(!_player.playing){
        [_player prepareToPlay];//分配所需的资源，并将其加入到内部播放队列中。
        [_player play];
    }else{
        NSLog(@"正在播放音乐s");
    }
}
-(void)setPlayerVolume{ //声音渐强效果
    _player.volume +=0.1;
    if (_player.volume>=1) {
        [_timer_volume invalidate];
        _timer_volume = nil;
    }
    NSLog(@"%.2f",_player.volume);
}
-(void)stopSound{
    
    if(_player &&_player.playing){ //如果 播放器 存在，并且正在播放，则首先暂停播放，然后释放掉播放器。
        [_player stop];
        _player=nil;
        [_timer_volume invalidate];
        _timer_volume = nil;
    }
    
}
-(void)startVibrate{
    if(_timer_vibrate==nil){
        _timer_vibrate=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
    }
}

-(void)vibrate{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

-(void)stopVibrate{
    if (_timer_vibrate!=nil) {
        [_timer_vibrate invalidate];
        _timer_vibrate=nil;
    }
    
}
-(void)setApplicationVolume:(float)value{
    UISlider *slider;
    MPVolumeView *slide = [MPVolumeView new];
    for (UIView *view in [slide subviews])
    {
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            slider = (UISlider*)view;
        }
    }
    //声音渐强
//    for (int i = 1; i<10; i++) {
//        slider.value =_receivedBean.soundVolume.floatValue/10;
//    }
    [slider setValue:value];
}
#pragma mark LocalNotification
-(void)registerNormalAlarm:(DataBean*)_bean{ //不带小睡的通知
    if (_bean.alarmDays.unsignedIntegerValue == EveryDay) {
        //对于当天的情况做如下处理：如果当天的提醒时间已过，则firedate修改为第二天，如果没过则不做处理，防止小睡提醒混乱
        //比如 早晨7点的闹铃，我在7点2分的时候设定，小睡时间为5分钟，则会在7点5分的时候响起，若修改为第二天，则当天不会响
        [LocalNotification RegisterLocalNotificationWithFireDate:[_bean.fireDate judgeAndSetToNextDay]
                                                      repeatType:NSCalendarUnitDay
                                                          entity:_bean];
    }else if(_bean.alarmDays.unsignedIntegerValue == 0){
        [LocalNotification RegisterLocalNotificationWithFireDate:[_bean.fireDate judgeAndSetToNextDay]
                                                      repeatType:0
                                                          entity:_bean];
    }else{
        for (int i = 0; i<7; i++) {
            if ((_bean.alarmDays.unsignedIntegerValue&(1<<i))>0) {
                int w = [_bean.fireDate weekday];
                NSDate *date = [_bean.fireDate dateByAddingTimeInterval:DayToIntervals*(i+1-w)];
                if ([[NSDate date] weekday] == i+1) { //如果是当天
                    date = [date judgeAndSetToNextWeek];
                }
                [LocalNotification RegisterLocalNotificationWithFireDate:date
                                                              repeatType:NSCalendarUnitWeekOfYear
                                                                  entity:_bean];
            }
        }
    }
}
-(void)registerNormalAlarm:(DataBean*)_bean WithNap:(BOOL)b{
    [self cancleLocalNotifications:_bean];
    if (b) {
        if (_bean.alarmDays.unsignedIntegerValue == EveryDay) {
            //对于当天的情况做如下处理：如果当天的提醒时间已过，则firedate修改为第二天，如果没过则不做处理，防止小睡提醒混乱
            //比如 早晨7点的闹铃，我在7点2分的时候设定，小睡时间为5分钟，则会在7点5分的时候响起，若修改为第二天，则当天不会响
            [LocalNotification RegisterLocalNotificationWithNapFireDate:[_bean.fireDate judgeAndSetToNextDay]
                                                          repeatType:NSCalendarUnitDay
                                                              entity:_bean];
        }else if(_bean.alarmDays.unsignedIntegerValue == 0){
            [LocalNotification RegisterLocalNotificationWithNapFireDate:[_bean.fireDate judgeAndSetToNextDay]
                                                          repeatType:0
                                                              entity:_bean];
        }else{
            for (int i = 0; i<7; i++) {
                if ((_bean.alarmDays.unsignedIntegerValue&(1<<i))>0) {
                    int w = [_bean.fireDate weekday];
                    NSDate *date = [_bean.fireDate dateByAddingTimeInterval:DayToIntervals*(i+1-w)];
                    if ([[NSDate date] weekday] == i+1) { //如果是当天
                        date = [date judgeAndSetToNextWeek];
                    }
                    [LocalNotification RegisterLocalNotificationWithNapFireDate:date
                                                                  repeatType:NSCalendarUnitWeekOfYear
                                                                      entity:_bean];
                }
            }
        }
    }else{
        [self registerNormalAlarm:_bean];
    }
}
-(void)registerLocalNotifications:(DataBean*)_bean{
    [self cancleLocalNotifications:_bean];
    switch (_bean.alarmType.unsignedIntegerValue) {
        case AlarmTypeDefault:{
            [self registerNormalAlarm:_bean];
        }
            break;
        case AlarmTypeReminder:{
        }
            break;
        case AlarmTypeCountDown:{
        }
            break;
        case AlarmTypeAbnormal:{
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"\n注册完成\n当前总的通知个数：%d",[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
//    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    for (UILocalNotification *l in array) {
//        NSLog(@"%@",l);
//    }

}
-(void)registerAllLocalNotificationsWithNap{ //程序被杀死之前，注册带有小睡的通知，下次启动重新注册为不带小睡的通知
    NSArray* array = [myCoreData queryAllOpenDataBeans];
    for (DataBean *bean in array) {
        [self registerNormalAlarm:bean WithNap:YES];
    }
}
-(void)registerAllLocalNotificationsWithoutNap{ //程序重新启动，注册为不带小睡的通知
    NSArray* array = [myCoreData queryAllOpenDataBeans];
    for (DataBean *bean in array) {
        [self registerNormalAlarm:bean WithNap:NO];
    }
}
-(void)cancleLocalNotifications:(DataBean *)_bean{
    [LocalNotification cancelRepeatLocalNotificationsBy:_bean.identifer];
    NSLog(@"\n删除完成\n当前总的通知个数：%d",[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}
-(void)cancleLocalNotificationsByNotificationIdentifer:(NSString*)NotificationIdentifer{
    [LocalNotification cancleLocalNotificationsByNotificationIdentifer:NotificationIdentifer];
}
#pragma mark alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == Tag_alert_normal_1) { //没有小睡 只有一个按键
        if (buttonIndex==0) {
            [self stopSound];
            [self stopVibrate];
        }
    }else if(alertView.tag == Tag_alert_normal_2){ //有小睡 两个按键 稍后提醒和停止提醒
        if (buttonIndex == 0) {//稍后提醒 不做处理 已经注册了通知
            [self stopSound];
            [self stopVibrate];
            [LocalNotification RegisterNapWithFireDate:[[NSDate date] dateByAddingTimeInterval:_receivedBean.napTime.unsignedIntegerValue*60]
                                                   Seq:[NSNumber numberWithInt:-1]
                                                entity:_receivedBean];
        }else{ //停止提醒
            [self stopSound];
            [self stopVibrate];
            if (_receivedBean.alarmDays.unsignedIntegerValue==0) { //有小睡的不重复闹钟 只取消不注册 点击停止后关闭
                _receivedBean.alarmState= [NSNumber numberWithBool:NO];
//                [myCoreData updateDataBean:_receivedBean];
            }
        }
    }else if(alertView.tag == Tag_alert_normal_3){
        if (buttonIndex==0) {
            [self stopSound];
            [self stopVibrate];
        }
    }else if(alertView.tag == Tag_alert_normal_4){
        if (buttonIndex == 0) {//稍后提醒 不做处理 已经注册了通知
            [self stopSound];
            [self stopVibrate];
            [LocalNotification RegisterNapWithFireDate:[[NSDate date] dateByAddingTimeInterval:_receivedBean.napTime.unsignedIntegerValue*60]
                                                   Seq:[NSNumber numberWithInt:-1]
                                                entity:_receivedBean];
        }else{ //停止提醒
            [self stopSound];
            [self stopVibrate];
            if (_receivedBean.alarmDays.unsignedIntegerValue==0) { //有小睡的不重复闹钟 只取消不注册 点击停止后关闭
                _receivedBean.alarmState= [NSNumber numberWithBool:NO];
//                [myCoreData updateDataBean:_receivedBean];
            }
        }
    }
    _ProcessFlag = NO; //保证同一个bean不被重复处理
    [myCoreData updateDataBean:_receivedBean]; //收到一个通知之后 更新一下bean.nextfiretime的状态
    [_homeVC refreshTableDataView];
}
@end
