//
//  MyActionSheet.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "MyActionSheet.h"

@implementation MyActionSheet
@synthesize mainWindow = _mainWindow;
@synthesize myWindow = _myWindow;
@synthesize myTitle = _myTitle;
@synthesize backView = _backView;
@synthesize myView = _myView;
@synthesize delegate = _delegate;
-(id)init{
    self = [super init];
    if (self) {
        _myWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _myWindow.windowLevel = UIWindowLevelStatusBar;
        _myWindow.userInteractionEnabled = YES;
        _myWindow.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.5f];
    }
    return self;
}

-(void)presentMyActionsheetWithView:(UIView *)view{
    
    _backView = [[UIView alloc] init];
    if (IOS6&&([view isKindOfClass:[UIDatePicker class]]|[view isKindOfClass:[UIPickerView class]])) {
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    }else{
        _backView.backgroundColor = [UIColor whiteColor];
    }
    
    CGRect f;
    f.size.width = 320;
    f.size.height =view.frame.size.height+60;
    f.origin.x = 0;
    f.origin.y = SCREEN_HEIGHT-f.size.height;
    _backView.frame = f;
    
    f = view.bounds;
    f.origin.y = 40;
    f.origin.x = (SCREEN_WIDTH - f.size.width)*0.5;
    view.frame = f;
    _myView = view;
    
    [_backView addSubview:view];
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(240, 0, 80, 40);
        [button setTitle:@"确定" forState:UIControlStateNormal];
        if (IOS6&&([view isKindOfClass:[UIDatePicker class]]|[view isKindOfClass:[UIPickerView class]])) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(callBack) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:button];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 80, 40);
        [button setTitle:@"取消" forState:UIControlStateNormal];
        if (IOS6&&([view isKindOfClass:[UIDatePicker class]]|[view isKindOfClass:[UIPickerView class]])) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(dismissMyActionSheet) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:button];
    }
    [_myWindow addSubview:_backView];
    
    CGPoint center = _backView.center;
    center.y += _backView.frame.size.height;
    _backView.center = center;
    [_myWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGPoint center = _backView.center;
        center.y -= _backView.frame.size.height;
        _backView.center = center;
    } completion:^(BOOL finished) {
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT-_backView.frame.size.height)];
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMyActionSheet)];
        [tapView addGestureRecognizer:tap];
        [_myWindow addSubview:tapView];
    }];
}
-(void)dismissMyActionSheet{
    if ([_delegate respondsToSelector:@selector(willDismissMyActionSheet:)]) {
        [_delegate willDismissMyActionSheet:self];
    }
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _myWindow.alpha = 0;
        CGPoint center = _backView.center;
        center.y += _backView.frame.size.height;
        _backView.center = center;
    } completion:^(BOOL finished) {
        _myWindow.hidden = YES;
        [_mainWindow makeKeyAndVisible];
        if ([_delegate respondsToSelector:@selector(didDismissMyActionSheet:)]) {
            [_delegate didDismissMyActionSheet:self];
        }    }];
}
-(void)callBack{
    if ([_delegate respondsToSelector:@selector(commitAction:withMyView:)]) {
        [_delegate commitAction:self withMyView:_myView];
    }
    [self dismissMyActionSheet];
}
@end
