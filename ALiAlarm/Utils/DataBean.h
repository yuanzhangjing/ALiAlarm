//
//  DataBean.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBean : NSObject
@property (nonatomic,strong) NSNumber* alarmType;
@property (nonatomic,strong) NSDate *fireDate;
@property (nonatomic,strong) NSNumber *napTime;
@property (nonatomic,strong) NSNumber *alarmDays;
@property (nonatomic,strong) NSNumber *ringType;
@property (nonatomic,strong) NSString *soundName;
@property (nonatomic,strong) NSNumber *soundVolume;
@property (nonatomic,strong) NSString *alarmLabel;
@property (nonatomic,strong) NSString *identifer;
@property (nonatomic,strong) NSNumber *alarmState;
@property (nonatomic,strong) NSString *weiboContent;
@property (nonatomic,strong) NSDate *updateTime;
@property (nonatomic,strong) NSDate *nextFiretime;
-(void)setDefaultValue:(AlarmType)alarmType;
@end

@interface myCoreData : NSObject

+(BOOL)insertDataBean:(DataBean*)bean;
+(BOOL)updateDataBean:(DataBean*)bean;
+(BOOL)deleteDataBean:(NSString *)identifer;
+(BOOL)deleteAllDataBeans;
+(DataBean*)queryDataBean:(NSString*)identifer;
+(NSArray*)queryDataBeans:(AlarmType)alarmType;
+(NSArray*)queryAllDataBeans;
+(NSArray*)queryAllOpenDataBeans;
@end