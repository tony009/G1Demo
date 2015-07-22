//
//  FunctionMenuViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/27.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "FunctionMenuViewController.h"
#import "WDImageButton.h"
#import "SwipingCardViewController.h"
@interface FunctionMenuViewController ()

@end

@implementation FunctionMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initSubViews];
}

-(void)_initSubViews{
    
    NSArray *labelArray = @[@"话费充值",@"机票服务",@"游戏点卡",@"基金理财",@"信用卡还款",@"余额查询",@"卡卡转账",@"交通违章",@"水电煤代缴"];
    NSArray *imgArray = @[@"话费充值",@"机票服务",@"游戏点卡",@"基金理财",@"信用卡还款",@"余额查询",@"卡卡转账",@"交通违章",@"水电煤代缴"];
    
    for (int i =0 ; i < labelArray.count; i++) {
        WDImageButton *button = (WDImageButton *)[self.functionView viewWithTag:i+10];
        button.imageName = [imgArray objectAtIndex:i];
        button.text = labelArray[i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"功能界面";
}

//查询余额
- (IBAction)checkAccountAction:(id)sender {
    //sendValue = @"查询余额";
    
    if(MiniPosSDKDeviceState()<0){
        //[self showTipView:@"设备未连接"];
        [self showConnectionAlert];
        return;
    }else {
        [self verifyParamsSuccess:^{
            
            if (MiniPosSDKGetCurrentSessionType()== SESSION_POS_UNKNOWN) {
                
                //[self performSegueWithIdentifier:@"chaxun" sender:self];
                SwipingCardViewController *scvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SC"];
                if ([scvc respondsToSelector:@selector(setType:)]) {
                    [scvc setValue:@"查询余额" forKey:@"type"];
                }
                [self.navigationController pushViewController:scvc animated:YES];
                
                if(MiniPosSDKQuery()>=0)
                {
                    NSLog(@"正在查询余额...");
                }
                
            }
            

        }];
        
    }
    
    
    
}

- (void)recvMiniPosSDKStatus
{

    [super recvMiniPosSDKStatus];
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到成功"]]) {
        [self hideHUD];
        [self showTipView:self.statusStr];
    }
    
    if ([self.statusStr isEqualToString:[NSString stringWithFormat:@"签到失败"]]) {
        [self hideHUD];
        NSLog(@"LoginViewController ----签到失败");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"签到失败！" message:self.displayString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
    }
    self.statusStr = @"";
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
