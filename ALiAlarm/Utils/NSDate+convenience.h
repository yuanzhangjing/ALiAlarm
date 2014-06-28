//
//  NSDate+convenience.h
//
//  Created by in 't Veen Tjeerd on 4/23/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Convenience)

-(NSDate *)offsetMonth:(int)numMonths;
-(NSDate *)offsetDay:(int)numDays;
-(NSDate *)offsetHours:(int)hours;
-(int)numDaysInMonth;
-(int)firstWeekDayInMonth;
-(int)year;
-(int)month;
-(int)day;
-(int)hour;
-(int)minute;
-(int)second;

-(NSString*)timeStamp;
-(NSDate *)judgeAndSetToNextWeek;
-(NSDate *)setToNextWeek;
-(NSDate *)judgeAndSetToNextDay;
-(NSDate *)setToNextDay;
-(NSDate *)hourandminute;
-(NSDate *)setToday;
-(NSDate *)setToDate:(NSDate*)oterdate; //设为同一天

-(NSComparisonResult)compareWithHHmm:(NSDate*)date;

+(NSDate *)dateStartOfDay:(NSDate *)date;
+(NSDate *)dateStartOfWeek;
+(NSDate *)dateEndOfWeek;

-(NSString*)DateToHHmm;
-(NSString*)DateTohhmm;
-(NSString*)DateToyyyyMMdd;
-(NSString*)DateToString:(NSString*)fomat;
-(int)weekday;
@end
