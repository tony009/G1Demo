//
//  ConnectDeviceViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/12/1.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "ConnectDeviceViewController.h"
#import "UIUtils.h"
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
    
    _deviceView = [[UIView alloc] initWithFrame:CGRectMake(10, kScreenHeight-200, kScreenWidth-20, 180)];
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
    
    curLabel = self.bleStatusLabel;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    if(MiniPosSDKDeviceState()==0){
        self.statusLabel.text = @"已连接";
        self.bleStatusLabel.text = @"已连接";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverDevice) name:kDidDiscoverDevice object:nil];

}


-(void)getPosParams{
    
    NSLog(@"didConnectDevice");
    
    char paramname[100];
    
    memset(paramname, 0x00, sizeof(paramname));
    strcat(paramname, "TerminalNo");
    strcat(paramname, "\x1C");
    strcat(paramname, "MerchantNo");
    strcat(paramname, "\x1C");
    strcat(paramname, "SnNo");
    
    MiniPosSDKGetParams("88888888", paramname);
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
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
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
    
    
    curLabel = self.bleStatusLabel;
    [[BleManager sharedManager] startScan];
    self.deviceView.hidden = NO;
    
}


//复写父类方法
- (void)recvMiniPosSDKStatus
{
    [super recvMiniPosSDKStatus];
    
    if([self.statusStr isEqualToString:@"设备已插入"]){
        NSLog(@"ConnectDevice:设备已经插入");
        curLabel.text = @"已连接";
        self.statusLabel.text =@"已连接";
        _isConnect = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            [self getPosParams];
            
        });
        
        
    }
    
    if ([self.statusStr isEqualToString:@"设备已拔出"]) {
        curLabel.text = @"未连接";
        self.statusLabel.text =@"未连接";
        _isConnect = NO;
    }

    if ([self.statusStr isEqualToString:@"获取参数成功"]) {
        
        NSString *SnNo = [NSString stringWithCString:MiniPosSDKGetParam("SnNo") encoding:NSUTF8StringEncoding];
        NSString *TerminalNo = [NSString stringWithCString:MiniPosSDKGetParam("TerminalNo") encoding:NSUTF8StringEncoding];
        NSString *MerchantNo = [NSString stringWithCString:MiniPosSDKGetParam("MerchantNo") encoding:NSUTF8StringEncoding];
        
        [[NSUserDefaults standardUserDefaults] setObject:SnNo forKey:kMposG1SN];
        [[NSUserDefaults standardUserDefaults] setObject:TerminalNo forKey:kMposG1TerminalNo];
        [[NSUserDefaults standardUserDefaults] setObject:MerchantNo forKey:kMposG1MerchantNo];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSLog(@"SnNo:%@,TerminalNo:%@,MerchantNo:%@",[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1SN],[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1TerminalNo],[[NSUserDefaults standardUserDefaults]stringForKey:kMposG1MerchantNo]);

        self.SN.text = [[NSUserDefaults standardUserDefaults]stringForKey:kMposG1SN];
        self.time.text = [UIUtils stringFromDate:[NSDate date] formate:@"yyyy.MM.dd"];
    }
    
    self.statusStr = @"";
    
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
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"设备目录";
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
    
    
    CBPeripheral *aper = [searchDevices objectAtIndex:indexPath.row];
    self.bluetoothName.text = aper.name;
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
