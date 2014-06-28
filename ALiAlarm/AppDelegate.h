//
//  AppDelegate.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "MyNavigationViewController.h"
#import "LocalNotification.h"
#import "DataBean.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>{
    NSTimer *_timer_vibrate;
    NSTimer *_timer_volume;
    NSTimer *_timer_fakeTask;
    DataBean *_receivedBean; //本地通知接受信息
//    NSString *_notificationIdentifer; //本地通知接受信息
//    UILocalNotification *_localNotification; //传来的本地通知 三个部分用完设为nil，保证及时释放
    NSInteger _seq;
    NSDate *_notiFireDate;
    AVAudioPlayer *audioplayer;
    BOOL _ProcessFlag;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) MyNavigationViewController *navigationController;
@property (strong, nonatomic) HomeViewController *homeVC;

@property (nonatomic) AVAudioPlayer * player;

@property UIBackgroundTaskIdentifier backgroundtaskidentifer;
@property (strong,nonatomic) NSTimer *backgroundTimer;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)registerLocalNotifications:(DataBean*)_bean;
-(void)cancleLocalNotifications:(DataBean*)_bean;
-(void)cancleLocalNotificationsByNotificationIdentifer:(NSString*)NotificationIdentifer;
-(NSDate*)getNextFiretime:(DataBean*)bean;
@end
