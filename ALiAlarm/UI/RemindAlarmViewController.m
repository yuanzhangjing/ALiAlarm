//
//  RemindAlarmViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "RemindAlarmViewController.h"

@interface RemindAlarmViewController ()

@end

@implementation RemindAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftButtonTitle=@"取消";
    self.rightButtonTitle = @"保存";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButtonClick:(UIButton *)leftButton{
    [super leftButtonClick:leftButton];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
