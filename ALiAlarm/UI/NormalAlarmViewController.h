//
//  NormalAlarmViewController.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "SuperViewController.h"
#import "DataBean.h"
@interface NormalAlarmViewController : SuperViewController

@property(strong,nonatomic) DataBean *bean;
@property(strong,nonatomic) UITableView *subTableView;
@end
