//
//  SuperViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "SuperViewController.h"
@interface SuperViewController ()

@end

@implementation SuperViewController
@synthesize navTitle = _navTitle;
@synthesize leftButtonTitle = _leftButtonTitle;
@synthesize rightButtonTitle = _rightButtonTitle;
@synthesize backButtonTitle = _backButtonTitle;

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
    self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];//UIColorFromRGB(0xF7F7F7);
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
-(void)RefreshNavButtonandTitle{
    MyNavigationViewController *nav = (MyNavigationViewController*)self.navigationController;
    [[nav navLabel] setText:_navTitle];
    if (_leftButtonTitle.length==0) {
        [nav.leftButton removeFromSuperview];
    }else{
        nav.leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
        nav.leftButton.frame = CGRectMake(0, 0, 80, 44);
        nav.leftButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nav.leftButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [nav.leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [nav.leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [nav.leftButton setTitle:_leftButtonTitle forState:UIControlStateNormal];
        [nav.navigationBar addSubview:nav.leftButton];
    }
    if (_rightButtonTitle.length==0) {
        [nav.rightButton removeFromSuperview];
    }else{
        nav.rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
        nav.rightButton.frame = CGRectMake(240, 0, 80, 44);
        nav.rightButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nav.rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [nav.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [nav.rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [nav.rightButton setTitle:_rightButtonTitle forState:UIControlStateNormal];
        [nav.navigationBar addSubview:nav.rightButton];
    }
    if (_backButtonTitle.length==0) {
        [nav.backButton removeFromSuperview];
    }else{
        nav.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
        nav.backButton.frame = CGRectMake(0, 0, 80, 44);
        nav.backButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nav.backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [nav.backButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [nav.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [nav.backButton setTitle:_backButtonTitle forState:UIControlStateNormal];
        [nav.navigationBar addSubview:nav.backButton];
    }
}
-(void)ClearNavButtonandTitle{
    MyNavigationViewController *nav = (MyNavigationViewController*)self.navigationController;
    [[nav navLabel] setText:nil];
    [nav.backButton removeFromSuperview];
    [nav.leftButton removeFromSuperview];
    [nav.rightButton removeFromSuperview];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self ClearNavButtonandTitle];
    [self RefreshNavButtonandTitle];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftButtonClick:(UIButton*)button{
    NSLog(@"left");
}
-(void)rightButtonClick:(UIButton*)button{
    NSLog(@"right");
}
-(void)backButtonClick:(UIButton*)button{
    NSLog(@"back");
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
-(CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}
-(void)ViewMoveUpWith:(CGFloat)height{
    
    [UIView beginAnimations:@"viewup" context:Nil];
    [UIView setAnimationDuration:.3f];
    CGRect f = self.view.frame;
    if (0){
        f.origin.y = IOS7?64:0;
    }else{
        f.origin.y=(IOS7?64:0)-height;
    }
    self.view.frame = f;
    [UIView commitAnimations];
}
-(void)ViewBackNormal{
    [self ViewMoveUpWith:0];
}
@end