//
//  NormalAlarmViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-22.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "NormalAlarmViewController.h"
#import "MyActionSheet.h"
#import "NSDate+convenience.h"
#import "RingListViewController.h"
#import "AppDelegate.h"
#define Tag_DatePicker 1001
#define Tag_TextField 1002
@interface NormalAlarmViewController ()<UITableViewDataSource,UITableViewDelegate,MyActionSheetDelegate,UITextFieldDelegate>{
    NSMutableArray *napsArray;
    NSMutableArray *daysArray;
    NSMutableArray *typesArray;
    MyActionSheet *_action;
}
@end

@implementation NormalAlarmViewController
@synthesize subTableView=_subTableView;
@synthesize bean = _bean;
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
    if (!_bean) {
        _bean=[[DataBean alloc] init];
        [_bean setDefaultValue:AlarmTypeDefault];
    }
    self.leftButtonTitle=@"取消";
    self.rightButtonTitle = @"保存";
    
    _subTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, CONTENT_VIEW_HEIGHT) style:UITableViewStyleGrouped];
    _subTableView.delegate = self;
    _subTableView.dataSource = self;
    _subTableView.backgroundColor = [UIColor clearColor];
    _subTableView.backgroundView = nil;
    _subTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [self.view addSubview:_subTableView];
    
    napsArray = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"round_yellow"] forState:UIControlStateSelected];
        if (i==0) {
            [button setTitle:@"1" forState:UIControlStateNormal];
        }else{
            [button setTitle:[NSString stringWithFormat:@"%d",i*5] forState:UIControlStateNormal];
        }
        button.selected =_bean.napTime.unsignedIntegerValue==button.titleLabel.text.integerValue;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [napsArray addObject:button];
        [button addTarget:self action:@selector(napSelect:) forControlEvents:UIControlEventTouchDown];
    }
    daysArray = [[NSMutableArray alloc] initWithCapacity:7];
    for (NSUInteger i = 0; i<7; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"round_yellow"] forState:UIControlStateSelected];
        [button setTitle:[self numberToStr:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [daysArray addObject:button];
        button.selected =(_bean.alarmDays.unsignedIntegerValue&(1<<i))>0;
        [button addTarget:self action:@selector(daySelect:) forControlEvents:UIControlEventTouchDown];
    }
    typesArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"round_gray"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"round_yellow"] forState:UIControlStateSelected];
        if (i==0) {
            [button setTitle:@"铃" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"振" forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typesArray addObject:button];
        button.selected = (_bean.ringType.unsignedIntegerValue&(1<<i))>0;
        [button addTarget:self action:@selector(typeSelect:) forControlEvents:UIControlEventTouchDown];
    }
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
-(void)leftButtonClick:(UIButton *)leftButton{
    [super leftButtonClick:leftButton];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)rightButtonClick:(UIButton *)button{
    [super rightButtonClick:button];
    _bean.alarmLabel = [(UITextField*)[self.view viewWithTag:Tag_TextField] text];
    _bean.alarmState = [NSNumber numberWithDouble:YES];
    if ([self.navTitle isEqualToString:@"编辑闹钟"]) {
        if ([myCoreData updateDataBean:_bean]) {
            NSLog(@"更新完成！");
        }else{
            NSLog(@"更新失败！");
        }
    }else{
        if ([myCoreData insertDataBean:_bean]) {
            NSLog(@"插入成功！");
        }else{
            NSLog(@"插入失败！");
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [[APP_DELEGATE homeVC] refreshTableDataView];
        [APP_DELEGATE registerLocalNotifications:_bean];
    }];
}
-(void)napSelect:(UIButton*)button{
    _bean.napTime = [NSNumber numberWithUnsignedInteger:0];
    if (button.selected) {
        button.selected = NO;
    }else{
        for (UIButton *btn in napsArray) {
            btn.selected = NO;
        }
        button.selected = YES;
        _bean.napTime = [NSNumber numberWithUnsignedInteger:button.titleLabel.text.integerValue];
    }
}
-(void)daySelect:(UIButton*)button{
    button.selected = !button.selected;
    int i = [daysArray indexOfObject:button];
    _bean.alarmDays = [NSNumber numberWithUnsignedInteger:_bean.alarmDays.unsignedIntegerValue ^ (1<<i)];
}
-(void)typeSelect:(UIButton*)button{
    button.selected = !button.selected;
    int i = [typesArray indexOfObject:button];
    _bean.ringType = [NSNumber numberWithUnsignedInteger:_bean.ringType.unsignedIntegerValue ^ (1<<i)];
}
-(void)changeVolume:(UISlider*)slider{
    _bean.soundVolume = [NSNumber numberWithFloat:slider.value];
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
    NSString* titleCellIdentifier = [NSString stringWithFormat:@"cell:%d_%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
	}else{
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text = @"时间：";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x63B8FF, 1.0f);
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"HH:mm"];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [format stringFromDate:_bean.fireDate];
            label.font = [UIFont systemFontOfSize:20];
            [cell.contentView addSubview:label];
        }
            break;
        case 1:{
            cell.textLabel.text = @"小睡：";
            for (int i = 0; i<napsArray.count; i++) {
                UIButton *button = [napsArray objectAtIndex:i];
                button.frame = CGRectMake(80+i*50, 5, 30, 30);
                [cell.contentView addSubview:button];
            }
        }
            break;
        case 2:{
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = @"重复：\n\n\n";
            for (int i = 0; i<daysArray.count; i++) {
                UIButton *button = [daysArray objectAtIndex:i];
                button.frame = CGRectMake(20+40*i, 40, 30, 30);
                [cell.contentView addSubview:button];
            }
        }
            break;
        case 3:{
            cell.textLabel.text = @"类型：";
            for (int i = 0; i<typesArray.count; i++) {
                UIButton *button = [typesArray objectAtIndex:i];
                button.frame = CGRectMake(80+i*50, 5, 30, 30);
                [cell.contentView addSubview:button];
            }
        }
            break;
        case 4:{
            cell.textLabel.text = @"铃声：";
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x63B8FF, 1.0f);
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = _bean.soundName;
            label.font = [UIFont systemFontOfSize:18];
            [cell.contentView addSubview:label];
        }
            break;
        case 5:{
            cell.textLabel.text = @"音量：";
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 0, 220, 40)];
            [slider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
            slider.value = _bean.soundVolume.floatValue;
            slider.maximumValue=1.0;
            slider.minimumValue = 0;
            [cell.contentView addSubview:slider];
        }
            break;
        case 6:{
            cell.textLabel.text = @"标签：";
            UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 220, 40)];
            tf.delegate = self;
            tf.tag = Tag_TextField;
//            tf.textAlignment = NSTextAlignmentCenter;
            tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            if (_bean.alarmLabel.length>0) {
                tf.text = _bean.alarmLabel;
            }else{
                tf.placeholder = @"闹钟标签";
            }
            tf.keyboardType = UIKeyboardTypeDefault;
            tf.returnKeyType = UIReturnKeyDone;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:tf];
        }
            break;
            
        default:
            break;
    }
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        return 80;
    }
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return IPHONE5?10:5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return IPHONE5?10:5;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self ViewBackNormal];
    if (indexPath.section==0) {
        _action = [[MyActionSheet alloc] init];
        _action.delegate = self;
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        datePicker.tag = Tag_DatePicker;
        datePicker.date = _bean.fireDate;
        datePicker.datePickerMode = UIDatePickerModeTime;
        datePicker.timeZone = [NSTimeZone defaultTimeZone];
        [_action presentMyActionsheetWithView:datePicker];
    }else if (indexPath.section == 4){
        RingListViewController *vc = [RingListViewController new];
        vc.navTitle = @"铃声列表";
        vc.bean = _bean;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark myactionsheet delegate
-(void)commitAction:(MyActionSheet *)sheet withMyView:(UIView *)myView{
    _bean.fireDate = [(UIDatePicker*)myView date];
    [_subTableView reloadData];
}
-(void)ViewBackNormal{
    [[self.view viewWithTag:Tag_TextField] resignFirstResponder];
    [super ViewBackNormal];
}
#pragma mark textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect = [_subTableView convertRect:[_subTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:6]] toView:self.view];
    double offset =260-(CONTENT_VIEW_HEIGHT - CGRectGetMaxY(rect));
    [self ViewMoveUpWith:offset];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self ViewBackNormal];
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self ViewBackNormal];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CGFloat a = [self widthOfString:textField.text withFont:textField.font];
    CGFloat b = [self widthOfString:string withFont:textField.font];
    if (b!=0&&a+b>200) {
        return NO;
    }
    return YES;
}
@end
