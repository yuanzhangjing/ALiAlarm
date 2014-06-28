//
//  SuperViewController.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyNavigationViewController.h"
#import "LocalNotification.h"

@interface SuperViewController : UIViewController

@property (strong, nonatomic) NSString *navTitle;

@property (strong,nonatomic) NSString *leftButtonTitle;
@property (strong,nonatomic) NSString *rightButtonTitle;
@property (strong,nonatomic) NSString *backButtonTitle;

-(void)leftButtonClick:(UIButton*)leftButton;
-(void)rightButtonClick:(UIButton*)button;
-(void)backButtonClick:(UIButton*)button;

-(CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font ;
-(void)ViewMoveUpWith:(CGFloat)height;
-(void)ViewBackNormal;
@end