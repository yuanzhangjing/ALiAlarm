//
//  SecondViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "SecondViewController.h"
#import "ProgressView.h"
#import "NSDate+convenience.h"
#define SecToDate(a) [NSString stringWithFormat:@"%02d:%02d:%02d",(int)(a)/3600,(int)(a)/60,(int)(a)%60]
@interface SecondViewController (){
    ProgressView *pv;
    UILabel *timeLabel;
    NSDate *startTime;
    NSDate *endTime;
    NSDateFormatter *formatter;
    NSTimer *timer;
}

@end

@implementation SecondViewController

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
    [self.navigationItem setHidesBackButton:YES];
    self.leftButtonTitle=@"取消";
    self.rightButtonTitle = @"保存";
    startTime = [NSDate date];
    endTime = [startTime dateByAddingTimeInterval:20.0f];
    pv = [[ProgressView alloc] initWithFrame:CGRectMake(0, CONTENT_VIEW_HEIGHT-160, 320, 160)];
    pv.degree=0;
    [self.view addSubview:pv];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm:ss"];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 40)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = @"00:00:00";
    [self.view addSubview:timeLabel];
    
//    [LocalNotification RegisterALocalNotificationWithFireDate:endTime
//                                                   repeatType:0
//                                                 NapInterval:10.0f
//                                                    AlertBody:@"Alarm is ringing!"
//                                                  AlertAction:@"查看"
//                                                    SoundName:@"梦幻.caf"
//                                                         Type:AlarmTypeCountDown
//                                                    Identifer:[[NSDate date] timeStamp]];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(refreshProgress) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshProgress{
    double timeLeft = [endTime timeIntervalSinceNow];
    double timeCount = [endTime timeIntervalSinceDate:startTime];
    timeLabel.text = SecToDate(ceil(timeLeft));
    pv.degree = 1-timeLeft/timeCount;
    NSLog(@"%.2f",timeLeft);
    if (pv.degree >=1) {
        [timer invalidate];
        timeLabel.text = SecToDate(0);
    }
}
-(void)leftButtonClick:(UIButton *)leftButton{
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
