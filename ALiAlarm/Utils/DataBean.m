//
//  DataBean.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "DataBean.h"
#import "AppDelegate.h"
#import "NSDate+convenience.h"
#import <objc/runtime.h>
@implementation DataBean
@synthesize alarmType = _alarmType;
@synthesize fireDate;
@synthesize napTime;
@synthesize alarmDays;
@synthesize ringType;
@synthesize soundName;
@synthesize soundVolume;
@synthesize alarmLabel;
@synthesize identifer;
@synthesize alarmState;
@synthesize updateTime;
@synthesize weiboContent;
@synthesize nextFiretime;
-(void)setDefaultValue:(AlarmType)alarmType{
    _alarmType = [NSNumber numberWithUnsignedInteger:alarmType];
    if (alarmType == AlarmTypeDefault) {
        fireDate = [[NSDate date] hourandminute];
    }else{
        fireDate = [NSDate date];
    }
    alarmState = [NSNumber numberWithBool:YES];
    napTime = [NSNumber numberWithUnsignedInteger:0];
    alarmDays = [NSNumber numberWithUnsignedInteger:0];
    ringType = [NSNumber numberWithUnsignedInteger:RingTypeRing|RingTypeVibrate];
    soundName = @"Let it go";
    soundVolume = [NSNumber numberWithFloat:0.8];
    alarmLabel = @"";
    identifer = [[NSDate date] timeStamp];
    weiboContent = @"";
    nextFiretime = [[NSDate date] hourandminute];
}
@end

@implementation myCoreData

+(void)DataBean:(DataBean*)abean toManagedObject:(NSManagedObject*)object{//存储
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList([abean class], &outCount);  //属性个数
        for(int i=0;i<outCount;i++)
        {
            objc_property_t property=properties[i];
            
            NSString *key=[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            id value = [abean performSelector:NSSelectorFromString(key)];
            [object setValue:value forKey:key]; //bean的property名字一定要和coredata内的名字对应起来
        }
}
+(void)ManagedObject:(NSManagedObject*)object toDataBean:(DataBean*)abean{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([abean class], &outCount);  //属性个数
    for(int i=0;i<outCount;i++)
    {
        objc_property_t property=properties[i];
        
        NSString *key=[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        id value = [object valueForKey:key];
        NSString *method=[NSString stringWithFormat:@"set%@%@:",
                          [[key substringToIndex:1] uppercaseString],
                          [key substringFromIndex:1]];
        [abean performSelector:NSSelectorFromString(method) withObject:value]; //bean的property名字一定要和coredata内的名字对应起来
    }
}
+(BOOL)insertDataBean:(DataBean *)bean{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(identifer = %@)",bean.identifer];
    [request setPredicate:pred];
    NSArray* objects = [context executeFetchRequest:request error:&error];
    NSManagedObject *object = nil;
    if (objects == nil) {
        NSLog(@"error!");
        return NO;
    }
    if (objects.count>0) {
        NSLog(@"已经存在！");
        return NO;
    }else{
        object = [NSEntityDescription insertNewObjectForEntityForName:@"AlarmEntity" inManagedObjectContext:context];
    }
    if (bean.alarmState.boolValue) {
        bean.nextFiretime = [APP_DELEGATE getNextFiretime:bean];
    }else{
        bean.nextFiretime = nil;
    }
    bean.updateTime = [NSDate date];  //添加插入时间
    [self DataBean:bean toManagedObject:object];
    return [context save:&error];
}
+(BOOL)updateDataBean:(DataBean*)bean{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"identifer == %@",bean.identifer];
    [request setPredicate:pre];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        NSLog(@"不存在！");
        return NO;
    }
    NSManagedObject *object = [objects objectAtIndex:0];
    if (bean.alarmState.boolValue) {
        bean.nextFiretime = [APP_DELEGATE getNextFiretime:bean];
    }else{
        bean.nextFiretime = nil;
    }
    bean.updateTime = [NSDate date];  //添加插入时间
    [self DataBean:bean toManagedObject:object];
    return [context save:&error];
}
+(BOOL)deleteDataBean:(NSString *)identifer{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSError *error;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifer == %@",identifer];
    [request setPredicate:pred];
    NSArray* objects = [context executeFetchRequest:request error:&error];
    NSManagedObject *object = [objects objectAtIndex:0];
    if (objects == nil) {
        NSLog(@"error!");
        return NO;
    }
    if (objects.count==0) {
        NSLog(@"不存在！");
        return NO;
    }else{
        [context deleteObject:object];
    }
    if (object.isDeleted) {
        NSLog(@"准备删除！");
    }else{
        NSLog(@"删除失败！");
    }
    return [context save:&error];
}
+(BOOL)deleteAllDataBeans{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        NSLog(@"error!");
        return NO;
    }
    if (objects.count==0) {
        NSLog(@"不存在！");
        return NO;
    }
    for (NSManagedObject *object in objects) {
        [context deleteObject:object];
    }
    return [context save:&error];
}
+(NSArray*)queryAllDataBeans{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        NSLog(@"查询内容为空");
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:objects.count];
    DataBean *abean;
    for (NSManagedObject *object in objects) {
        abean = [[DataBean alloc] init];
        [self ManagedObject:object toDataBean:abean];
        [results addObject:abean];
    }
    return results;
}
+(DataBean*)queryDataBean:(NSString *)identifer{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"identifer == %@",identifer];
    [request setPredicate:pre];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        return nil;
    }
    DataBean *bean = [[DataBean alloc] init];
    [self ManagedObject:[objects objectAtIndex:0] toDataBean:bean];
    return bean;
}
+(NSArray*)queryDataBeans:(AlarmType)alarmType{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"alarmType = %d",alarmType];
    [request setPredicate:pre];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        NSLog(@"查询内容为空");
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:objects.count];
    DataBean *abean;
    for (NSManagedObject *object in objects) {
        abean = [[DataBean alloc] init];
        [self ManagedObject:object toDataBean:abean];
        [results addObject:abean];
    }
    return results;
}
+(NSArray*)queryLatelyBeans{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"alarmState = %d",1];
    [request setPredicate:pre];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        NSLog(@"查询内容为空");
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:objects.count];
    DataBean *abean;
    for (NSManagedObject *object in objects) {
        abean = [[DataBean alloc] init];
        [self ManagedObject:object toDataBean:abean];
        [results addObject:abean];
    }
    return results;
}
+(NSArray*)queryAllOpenDataBeans{
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AlarmEntity"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"alarmState = %d",1];
    [request setPredicate:pre];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error;
    NSArray* objects = [context executeFetchRequest:request error:&error];
    if (objects.count == 0) {
        NSLog(@"查询内容为空");
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:objects.count];
    DataBean *abean;
    for (NSManagedObject *object in objects) {
        abean = [[DataBean alloc] init];
        [self ManagedObject:object toDataBean:abean];
        [results addObject:abean];
    }
    return results;
}
@end