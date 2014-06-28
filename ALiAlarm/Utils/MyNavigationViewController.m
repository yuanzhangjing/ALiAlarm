//
//  MyNavigationViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "MyNavigationViewController.h"

@interface MyNavigationViewController ()
@end

@implementation MyNavigationViewController
@synthesize navLabel = _navLabel;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize backButton = _backButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //change the color of navigationbar
        if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            [self.navigationBar setBarTintColor:[UIColor whiteColor]];
        }else{
            [self.navigationBar setTintColor:[UIColor whiteColor]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //add a Title for navigationbar
    _navLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 220, 44)];
    _navLabel.backgroundColor = [UIColor clearColor];
    _navLabel.textColor = [UIColor blackColor];
    _navLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    _navLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationBar addSubview:_navLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
