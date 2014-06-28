//
//  LocalNotification.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-21.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBean.h"
@interface LocalNotification : NSObject

+(UILocalNotification*)RegisterLocalNotificationWithFireDate:(NSDate *)firedate //后台运行的本地通知
                                       repeatType:(NSCalendarUnit)repeatInterval
                                           entity:(DataBean*)bean;

+(NSArray*)RegisterLocalNotificationWithNapFireDate:(NSDate *)firedate //程序杀死的本地通知
                                         repeatType:(NSCalendarUnit)repeatInterval
                                             entity:(DataBean *)bean;

+(UILocalNotification*)RegisterNapWithFireDate:(NSDate *)firedate //稍后提醒单独通知
                                           Seq:(NSNumber*)sequence
                                        entity:(DataBean*)bean;
+(void)cancelAllLocalNotifications; //all
+(void)cancelALocalNotification:(UILocalNotification*)locn; //a single one
+(void)cancelRepeatLocalNotificationsBy:(NSString*)iden; //by identifer
+(void)cancleLocalNotificationsByNotificationIdentifer:(NSString *)iden;//by notificationidentifer
@end
