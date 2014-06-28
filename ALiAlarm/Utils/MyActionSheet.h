//
//  MyActionSheet.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyActionSheetDelegate;

@interface MyActionSheet : NSObject

@property (strong,nonatomic) UIWindow *mainWindow;
@property (strong,nonatomic) UIWindow *myWindow;
@property (strong,nonatomic) NSString *myTitle;
@property (strong,nonatomic) UIView *backView;
@property (weak,nonatomic) UIView *myView;
@property (weak) id<MyActionSheetDelegate> delegate;
-(void)dismissMyActionSheet;
-(void)presentMyActionsheetWithView:(UIView*)view;
@end

@protocol MyActionSheetDelegate <NSObject>

@optional
-(void)willDismissMyActionSheet:(MyActionSheet*)sheet;
-(void)didDismissMyActionSheet:(MyActionSheet*)sheet;
-(void)commitAction:(MyActionSheet*)sheet withMyView:(UIView*)myView;
@end