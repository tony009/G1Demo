//
//  ConnectDeviceViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/12/1.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "ConnectDeviceViewController.h"

@interface ConnectDeviceViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSTimer *timer;
    UILabel *curLabel;
}
@end

@implementation ConnectDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isNeedAutoConnect = NO;
    [self _initSubViews];
    

    
}

- (void)_initSubViews
{
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    //    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    //    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _deviceView = [[UIView alloc] initWithFrame:CGRectMake(10, kScreenHeight-64-200, kScreenWidth-20, 180)];
    _deviceView.layer.cornerRadius = 20.0;
    _deviceView.layer.masksToBounds = YES;
    _deviceView.hidden = YES;
    _deviceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_deviceView];
    
    _deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-20, 140) style:UITableViewStylePlain];
    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
    _deviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_deviceView addSubview:_deviceTable];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 140, kScreenWidth-20, 40);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_deviceView addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(MiniPosSDKDeviceState()==0){
        self.statusLabel.text = @"已连接";
        self.bleStatusLabel.text = @"已连接";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverDevice) name:kDidDiscoverDevice object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isNeedAutoConnect = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)bleConnectAction:(UIButton *)sender {
    
    NSString *zhongduan = [[NSUserDefaults standardUserDefaults] objectForKey:kZhongDuanEditor];
    if (zhongduan == nil) {
        [self showTipView:@"你还未设置终端号！请先进入系统设置完成信息设置。"];
        return;
    }
    
    curLabel = self.bleStatusLabel;
    
    self.audioStatusLabel.text = @"未连接";
    //self.statusLabel.text = @"未连接";
    
    //MiniPosSDKInit();
    //DeviceDriverInterface *t;
    //t=GetBLEDeviceInterface();
    //MiniPosSDKRegisterDeviceInterface(t);
    [[BleManager sharedManager] startScan];
    self.deviceView.hidden = NO;
    
}

- (IBAction)audioConnectAction:(UIButton *)sender {
    
    
    [self cancelAction];
    
    curLabel = self.audioStatusLabel;
    self.bleStatusLabel.text = @"未连接";
    self.statusLabel.text = @"未连接";
     //MiniPosSDKRegisterDeviceInterface(GetAudioDeviceInterface());
}


//复写父类方法
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    if([self.statusStr isEqualToString:@"设备已插入"]){
        curLabel.text = @"已连接";
        _isConnect = YES;
    }else {
        curLabel.text = @"未连接";
        _isConnect = NO;
    }
    
}

#pragma mark -
#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-20, 44)];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 100;
        [cell.contentView addSubview:label];
        
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    
    CBPeripheral *aper = [searchDevices objectAtIndex:indexPath.row];
    label.text = aper.name;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-20, 40)];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"请选择连接设备";
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _deviceView.hidden = YES;
    [[BleManager sharedManager].imBT connect:[searchDevices objectAtIndex:indexPath.row]];
}

- (void)cancelAction
{
    self.deviceView.hidden = YES;
}

- (void)didDiscoverDevice
{
    [_deviceTable reloadData];
}



@end
