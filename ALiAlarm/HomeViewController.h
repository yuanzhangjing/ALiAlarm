//
//  HomeViewController.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
@interface HomeViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic) UITableView *subTableView;
-(void)refreshTableDataView;
@end
