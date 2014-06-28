//
//  RingListViewController.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-23.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "RingListViewController.h"
#import "NormalAlarmViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface RingListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_subTableView;
    NSArray *ringsArray;
    AVAudioPlayer *_player;
}

@end

@implementation RingListViewController
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
    self.navigationItem.hidesBackButton = YES;
    self.backButtonTitle = @"返回";
    ringsArray = [USER_DEFAULT arrayForKey:RINGS];
    
    {
        _subTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, CONTENT_VIEW_HEIGHT)];
        _subTableView.delegate = self;
        _subTableView.dataSource = self;
//        [_subTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)]];
        [_subTableView setTableFooterView:[[UIView alloc] init]];
        [self.view addSubview:_subTableView];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backButtonClick:(UIButton *)button{
    [super backButtonClick:button];
    [[(NormalAlarmViewController*)[self.navigationController.viewControllers objectAtIndex:0] subTableView] reloadData];
    [self stopSound];
    [self.navigationController popViewControllerAnimated:YES];
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
    cell.textLabel.text = [ringsArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([_bean.soundName isEqualToString:[ringsArray objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x63B8FF, 1.0f);
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ringsArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _bean.soundName = [ringsArray objectAtIndex:indexPath.row];
    [_subTableView reloadData];
    [self playSound];
}
#pragma mark audio
-(void)playSound{
    if(!_player){ // 如果没有定义 player实例，则 定义新的 player 实例。
        NSString * path = [[NSBundle mainBundle] pathForResource:_bean.soundName ofType:@"caf"];
        //该方法 返回 主束文件夹下 “莫斯科没有眼泪.mp3” 文件的路径字符串，如果没有该文件的话，返回null。
        
        //NSLog(@"music file path:%@",path);
        
        if(path==nil)return;//如果 没有音乐问文件，则直接退出，否者执行下面代码 回出问题。
        
        NSURL * url = [NSURL fileURLWithPath:path];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];//实例化 一个player 并指定其播放的歌曲。
        _player.numberOfLoops=1;//设置循环播放的次数： -1 代表 一直循环播放！
        _player.volume=1;
        
    }
    
    if(!_player.playing){
        [_player prepareToPlay];//分配所需的资源，并将其加入到内部播放队列中。
        [_player play];
    }else{
        [self stopSound];
        [self playSound];
    }
}

-(void)stopSound{
    if(_player &&_player.playing){ //如果 播放器 存在，并且正在播放，则首先暂停播放，然后释放掉播放器。
        [_player stop];
        _player=nil;
    }
    
}
@end
