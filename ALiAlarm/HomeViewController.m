//
//  HomeViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "HomeViewController.h"
#import "SecondViewController.h"
#import "NormalAlarmViewController.h"
#import "RemindAlarmViewController.h"
#import "AbnormalAlarmViewController.h"
#import "CountDownViewController.h"
#import "NSDate+convenience.h"
#import "DrawView.h"
#import "DataBean.h"
#import "AppDelegate.h"
#define Tag_TimeLabel 1001
#define Tag_PopButton 1002
#define Tag_Switch 1100 //1100~1199
#define Tag_Alert 1200 //1200~1299
@interface HomeViewController ()<UIAlertViewDelegate>{
    DrawView *popView;
    NSArray *records;
    UILabel *notilabel;
}

@end

@implementation HomeViewController
@synthesize subTableView = _subTableView;
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
    self.navTitle = @"alialarm";
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTimeLabel) userInfo:nil repeats:YES];
    DrawView *bgview = [[DrawView alloc] initWithFrame:CGRectMake(80, 10, 160, 160)];
    bgview.shape = DrawShapeCircle;
    bgview.myColor = UIColorFromRGBA(0x63B8FF,1.0);
    [self.view addSubview:bgview];
    notilabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [self.view addSubview:notilabel];
    
    {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40, 280, 60)];
        timeLabel.font = [UIFont systemFontOfSize:50];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.tag = Tag_TimeLabel;
        int hour = [[NSDate date] hour];
        int minute = [[NSDate date] minute];
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,minute];
        [self.view addSubview:timeLabel];
    }
    {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,110, 280, 30)];
        tempLabel.font = [UIFont systemFontOfSize:16.0f];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.textAlignment = NSTextAlignmentCenter;
        tempLabel.text=@"23℃~32℃";
        [self.view addSubview:tempLabel];
    }
    records = [myCoreData queryAllDataBeans];
    {
        _subTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, 320, CONTENT_VIEW_HEIGHT-180-50)];
        _subTableView.delegate = self;
        _subTableView.dataSource = self;
        [_subTableView setTableFooterView:[[UIView alloc] init]];
        [self.view addSubview:_subTableView];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = Tag_PopButton;
    [button setFrame:CGRectMake(140, CONTENT_VIEW_HEIGHT-50, 40, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"red_plus_up"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    button.selected = NO;
    [self.view addSubview:button];
}
-(void)refreshTableDataView{
    records = [myCoreData queryAllDataBeans];
    [_subTableView reloadData];
}
-(NSString*)numberToStr:(int)i{
    NSString * str;
    if (i>6) {
        i = i/6;
    }
    switch (i) {
        case 0:
            str=@"一";
            break;
        case 1:
            str=@"二";
            break;
        case 2:
            str=@"三";
            break;
        case 3:
            str=@"四";
            break;
        case 4:
            str=@"五";
            break;
        case 5:
            str=@"六";
            break;
        case 6:
            str=@"日";
            break;
            
        default:
            break;
    }
    return str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshTimeLabel{
    notilabel.text = [NSString stringWithFormat:@"当前通知总数为:%d个",[[UIApplication sharedApplication] scheduledLocalNotifications].count];
    notilabel.textAlignment = NSTextAlignmentCenter;
    UILabel *label = (UILabel*)[self.view viewWithTag:Tag_TimeLabel];
    int hour = [[NSDate date] hour];
    int minute = [[NSDate date] minute];
    label.text = [NSString stringWithFormat:@"%02d:%02d",hour,minute];
}
-(void)pop:(UIButton*)button{
    if (button.selected) {
        CGRect f = popView.frame;
        [UIView animateWithDuration:0.3 animations:^{
            button.transform = CGAffineTransformRotate(button.transform, M_PI_4);
            popView.frame = CGRectMake(CGRectGetMidX(f), CGRectGetMaxY(f), 0, 0);
        }completion:^(BOOL finished){
            popView.hidden = YES;
            popView.frame = f;
        }];
    }else{
        [UIView beginAnimations:@"rotate" context:Nil];
        [UIView setAnimationDuration:0.25f];
        button.transform = CGAffineTransformRotate(button.transform, -M_PI_4);
        [UIView commitAnimations];
        
        NSMutableArray* values=[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:1.1], [NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.0],nil];
        CAKeyframeAnimation * anim1=[CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim1.values=values;
        anim1.duration=0.3;
        
        if (popView) {
            [popView.layer addAnimation:anim1 forKey:nil];
            popView.hidden = NO;
        }else{
            popView = [[DrawView alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(button.frame)-50, 220, 60)];
            popView.shape = DrawShapeBubble;
            popView.myColor = [UIColor colorWithWhite:0 alpha:0.8];
            
            [popView.layer addAnimation:anim1 forKey:nil];
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setFrame:CGRectMake(0, 0, 70, 50)];
                [button setTitle:@"普通闹钟" forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(addAlarm:) forControlEvents:UIControlEventTouchUpInside];
                [popView addSubview:button];
            }
            {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(72, 10, 1, 30)];
                line.backgroundColor = [UIColor whiteColor];
                [popView addSubview:line];
            }
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setFrame:CGRectMake(75, 0, 70, 50)];
                [button setTitle:@"提醒闹钟" forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(addAlarm:) forControlEvents:UIControlEventTouchUpInside];
                [popView addSubview:button];
            }
            {
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(147, 10, 1, 30)];
                line.backgroundColor = [UIColor whiteColor];
                [popView addSubview:line];
            }
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setFrame:CGRectMake(150, 0, 70, 50)];
                [button setTitle:@"变态闹钟" forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(addAlarm:) forControlEvents:UIControlEventTouchUpInside];
                [popView addSubview:button];
            }
            [self.view addSubview:popView];
        }
    }
    button.selected = !button.selected;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UIButton *button = (UIButton*)[self.view viewWithTag:Tag_PopButton];
    if (button.selected) {
        [self pop:button];
    }
}
-(void)addAlarm:(UIButton*)button{
    SuperViewController *vc;
    if ([button.titleLabel.text isEqualToString:@"普通闹钟"]) {
        vc = [NormalAlarmViewController new];
    }else if([button.titleLabel.text isEqualToString:@"提醒闹钟"]){
        vc = [RemindAlarmViewController new];
    }else{
        vc = [AbnormalAlarmViewController new];
    }
    MyNavigationViewController *nav = [[MyNavigationViewController alloc] initWithRootViewController:vc];
    vc.navTitle = button.titleLabel.text;
    [self presentViewController:nav animated:YES completion:^{
        UIButton *popButton = (UIButton*)[self.view viewWithTag:Tag_PopButton];
        [self pop:popButton];
    }];
}
-(void)changeSwitch:(UISwitch*)mswitch{
    DataBean *bean = [records objectAtIndex:mswitch.tag-Tag_Switch];
    bean.alarmState = [NSNumber numberWithDouble:mswitch.on];
    if (mswitch.on) {
        [APP_DELEGATE registerLocalNotifications:bean];
    }else{
        [APP_DELEGATE cancleLocalNotifications:bean];
    }
    if ([myCoreData updateDataBean:bean]) {
        NSLog(@"更新成功！");
    }else{
        NSLog(@"更新失败！");
    }
    [self refreshTableDataView]; //这里刷新列表是为了 更新下次响铃时间
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
#pragma mark -tableview Delegate & DataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* titleCellIdentifier = [NSString stringWithFormat:@"cell:%d_%d",indexPath.section,indexPath.row/10];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
	}else{
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    DataBean *bean = [records objectAtIndex:indexPath.row];
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, 30, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [bean.fireDate hour]<12?@"上午":@"下午";
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 80, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [bean.fireDate DateTohhmm];
        label.font = [UIFont systemFontOfSize:24.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 200, 20)];
        label.backgroundColor = [UIColor clearColor];
        if (bean.nextFiretime!=nil) {
            label.text = [NSString stringWithFormat:@"下次提醒时间:%@",[bean.nextFiretime DateToString:@"yy-MM-dd HH:mm"]];
        }
        
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:label];
    }
    if (bean.alarmDays.unsignedIntegerValue == 0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
        [button setTitle:@"不重复" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(20, 50, 60, 20);
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        button.userInteractionEnabled = NO;
        [cell.contentView addSubview:button];
    }else{
        for (NSUInteger i = 0; i<7; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"round_yellow"] forState:UIControlStateSelected];
            [button setTitle:[self numberToStr:i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.selected =(bean.alarmDays.unsignedIntegerValue&(1<<i))>0;
            button.frame = CGRectMake(20+30*i, 50, 20, 20);
            button.userInteractionEnabled = NO;
            [cell.contentView addSubview:button];
        }
    }
    for (int i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"round_yellow"] forState:UIControlStateSelected];
        if (i==0) {
            [button setTitle:@"铃" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"振" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.selected = (bean.ringType.unsignedIntegerValue&(1<<i))>0;
        button.frame = CGRectMake(170+i*30, 10, 20, 20);
        button.userInteractionEnabled = NO;
        [cell.contentView addSubview:button];
    }
    UISwitch * mswitch = [[UISwitch alloc] initWithFrame:CGRectMake(240, 30, 40, 20)];
    mswitch.on = bean.alarmState.boolValue;
    mswitch.tag = Tag_Switch+indexPath.row;
    [mswitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
//    [cell.contentView addSubview:mswitch];
    cell.accessoryView = mswitch;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x63B8FF, 1.0f);
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return records.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    SecondViewController *vc = [[SecondViewController alloc] init];
    DataBean *bean = [records objectAtIndex:indexPath.row];
    switch (bean.alarmType.unsignedIntegerValue) {
        case AlarmTypeDefault:{
            NormalAlarmViewController *vc = [NormalAlarmViewController new];
            vc.navTitle = @"编辑闹钟";
            vc.bean = bean;
            MyNavigationViewController *nav = [[MyNavigationViewController alloc] initWithRootViewController:vc];
            nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case AlarmTypeReminder:{
            RemindAlarmViewController *vc = [RemindAlarmViewController new];
            vc.navTitle = @"提醒闹钟";
            MyNavigationViewController *nav = [[MyNavigationViewController alloc] initWithRootViewController:vc];
            nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case AlarmTypeCountDown:{
            CountDownViewController *vc = [CountDownViewController new];
            vc.navTitle = @"倒计时";
            MyNavigationViewController *nav = [[MyNavigationViewController alloc] initWithRootViewController:vc];
            nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case AlarmTypeAbnormal:{
            AbnormalAlarmViewController *vc = [AbnormalAlarmViewController new];
            vc.navTitle = @"变态闹钟";
            MyNavigationViewController *nav = [[MyNavigationViewController alloc] initWithRootViewController:vc];
            nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// 指定tableView 处于编辑状态时，左边出现减号时，是否缩进。return NO 时，出现减号时，cell不缩进，return YES时，cell自动缩进。
//cell中有一个contentView 当你把控件放到contentView中时，无论返回YES还是NO，这个contentView 都是都会自动缩进的。并且出现减号时，cell右边的accessoryView自动隐藏。
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认要删除闹钟？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = Tag_Alert+indexPath.row;
    [alert show];
}
#pragma mark scrollview delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    UIButton *button = (UIButton*)[self.view viewWithTag:Tag_PopButton];
    if (button.selected) {
        [self pop:button];
    }
}
#pragma mark alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        int row = alertView.tag - Tag_Alert;
        [APP_DELEGATE cancleLocalNotifications:(DataBean*)[records objectAtIndex:row]];
        [myCoreData deleteDataBean:[(DataBean*)[records objectAtIndex:row] identifer]];
        records = [myCoreData queryAllDataBeans]; //删除闹钟 重新读取数据
        [_subTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
@end
