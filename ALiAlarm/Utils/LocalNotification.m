//
//  LocalNotification.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-21.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "LocalNotification.h"
#import "NSDate+convenience.h"
@implementation LocalNotification

+(UILocalNotification*)RegisterLocalNotificationWithFireDate:(NSDate *)firedate
                                       repeatType:(NSCalendarUnit)repeatInterval
                                           entity:(DataBean *)bean{
    
    UILocalNotification *ln = [self RegisterALocalNotificationWithFireDate:firedate
                                                                repeatType:repeatInterval
                                                                       Seq:[NSNumber numberWithUnsignedInteger:0]
                                                                    entity:bean];
    return ln;
}
+(NSArray*)RegisterLocalNotificationWithNapFireDate:(NSDate *)firedate
                                      repeatType:(NSCalendarUnit)repeatInterval
                                          entity:(DataBean *)bean{
    int times;
    if (bean.napTime.unsignedIntegerValue==0) {
        times = 1;
    }else{
        times = 3;
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:times];
    for (int i = 0; i<times; i++) {
        UILocalNotification *ln = [self RegisterALocalNotificationWithFireDate:[firedate dateByAddingTimeInterval:bean.napTime.unsignedIntegerValue*i*60]
                                                                    repeatType:repeatInterval
                                                                           Seq:[NSNumber numberWithUnsignedInteger:i+1]
                                                                        entity:bean];
        [array addObject:ln];
    }
    return array;
}
+(UILocalNotification*)RegisterALocalNotificationWithFireDate:(NSDate *)firedate
                                                   repeatType:(NSCalendarUnit)repeattype
                                                          Seq:(NSNumber*)sequence
                                                       entity:(DataBean *)bean{
    
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.repeatInterval = repeattype;
    localNoti.timeZone = [NSTimeZone systemTimeZone];
    localNoti.fireDate = firedate;
    NSString *mes;
    if (bean.alarmLabel.length>0) {
        mes = [NSString stringWithFormat:@"阿狸闹钟正在提醒！\n%@",bean.alarmLabel];
    }else{
        mes = @"阿狸闹钟正在提醒";
    }
    localNoti.alertAction = @"查看";
    localNoti.alertBody =mes;
    if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
        localNoti.soundName = [NSString stringWithFormat:@"%@.caf",bean.soundName];
    }else{
        localNoti.soundName = UILocalNotificationDefaultSoundName;
    }
    localNoti.applicationIconBadgeNumber = 1;
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc]init];

    [infoDict setObject:bean.identifer forKey:@"Identifer"];
    [infoDict setObject:sequence forKey:@"Sequence"];
    
    if(sequence.intValue==0){ // 如果后台运行 用默认铃声
        localNoti.soundName = UILocalNotificationDefaultSoundName;
    }
    localNoti.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    NSLog(@"\n=============Normal注册通知============\n%@\n=============Normal注册通知============",localNoti);
    return localNoti;
}
+(UILocalNotification*)RegisterNapWithFireDate:(NSDate *)firedate //稍后提醒单独通知
                                           Seq:(NSNumber*)sequence
                                        entity:(DataBean*)bean{
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.repeatInterval = 0;
    localNoti.timeZone = [NSTimeZone systemTimeZone];
    localNoti.fireDate = firedate;
    NSString *mes;
    if (bean.alarmLabel.length>0) {
        mes = [NSString stringWithFormat:@"阿狸闹钟正在提醒(小睡)！\n%@",bean.alarmLabel];
    }else{
        mes = @"阿狸闹钟正在提醒(小睡)";
    }
    localNoti.alertAction = @"查看";
    localNoti.alertBody =mes;
    localNoti.applicationIconBadgeNumber = 1;
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc]init];
    
    [infoDict setObject:bean.identifer forKey:@"NapIdentifer"];
    [infoDict setObject:sequence forKey:@"Sequence"];
    
    if ((bean.ringType.unsignedIntegerValue&RingTypeRing)>0) {
        localNoti.soundName = [NSString stringWithFormat:@"%@.caf",bean.soundName];
    }else{
        localNoti.soundName = UILocalNotificationDefaultSoundName;
    }
    localNoti.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    NSLog(@"\n=============Nap注册通知============\n%@\n=============Nap注册通知============",localNoti);
    return localNoti;
}
+(void)cancelAllLocalNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
+(void)cancelALocalNotification:(UILocalNotification *)locn{
    [[UIApplication sharedApplication] cancelLocalNotification:locn];
}
+(void)cancelRepeatLocalNotificationsBy:(NSString *)iden{
    int i = 0;
    for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[ln.userInfo objectForKey:@"Identifer"] isEqualToString:iden]) {
            [[UIApplication sharedApplication] cancelLocalNotification:ln];
            NSLog(@"\n=============删除通知============\n%@\n=============删除通知============",ln);
            i++;
        }
    }
    NSLog(@"\n删除通知结果:\n个数=%d\nidentifer=%@ ",i,iden);
}
+(void)cancleLocalNotificationsByNotificationIdentifer:(NSString *)iden{
    int i = 0;
    for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[ln.userInfo objectForKey:@"NotificationIdentifer"] isEqualToString:iden]) {
            [[UIApplication sharedApplication] cancelLocalNotification:ln];
            NSLog(@"\n=============删除通知============\n%@\n=============删除通知============",ln);
            i++;
        }
    }
    NSLog(@"\n删除通知结果:\n个数=%d\nidentifer=%@ ",i,iden);
}
@end
