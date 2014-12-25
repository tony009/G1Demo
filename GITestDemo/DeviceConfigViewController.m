//
//  DeviceConfigViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/25.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "DeviceConfigViewController.h"
#import "UIUtils.h"

@interface DeviceConfigViewController ()
{
    UITapGestureRecognizer *disMissTap;
}
@end

@implementation DeviceConfigViewController

#define kOFFSET_FOR_KEYBOARD 120.0
#define kOFFSET_FOR_KEYBOARD_PAD 120.0

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    NSLog(@"%i",rect.size.height);
    if( (movedUp) )
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        if (rect.origin.y>=0)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                rect.origin.y -= kOFFSET_FOR_KEYBOARD;
                rect.size.height += kOFFSET_FOR_KEYBOARD;
            }
            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
                rect.origin.y -= kOFFSET_FOR_KEYBOARD_PAD;
                rect.size.height += kOFFSET_FOR_KEYBOARD_PAD;
            }
        }
    }
    else
    {
        if   (rect.origin.y<0)
            // revert back to the normal state.
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                rect.origin.y += kOFFSET_FOR_KEYBOARD;
                rect.size.height -= kOFFSET_FOR_KEYBOARD;
            }
            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
                rect.origin.y += kOFFSET_FOR_KEYBOARD_PAD;
                rect.size.height -= kOFFSET_FOR_KEYBOARD_PAD;
            }
            
        }
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setViewMovedUp:true];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self dismiss:self];
    return YES;
}

- (void) dismiss :(id)sender
{
    [self.view endEditing:YES];
    [self setViewMovedUp:false];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillshow:(NSNotification *)notification
{
    //获取键盘的高度
//    NSValue *sizeValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect frame = [sizeValue CGRectValue];
//    float height = CGRectGetHeight(frame);
    [self.view addGestureRecognizer:disMissTap];
//    [UIView animateWithDuration:0.35 animations:^{
//        self.bgScrollView.height = self.view.height - height;
//    }];
    
}
- (void)keyboardWillhide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:disMissTap];
//    [UIView animateWithDuration:0.35 animations:^{
//        self.bgScrollView.height = self.view.height;
//    }];
}

- (void)dismissAction
{
    [self.view endEditing:YES];
    [self dismiss:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)_initSubViews
{
    disMissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)];
    
    NSString *shangHuName = [[NSUserDefaults standardUserDefaults] stringForKey:kShangHuName];
    NSString *shangHu = [[NSUserDefaults standardUserDefaults] stringForKey:kShangHuEditor];
    NSString *zhongDuan = [[NSUserDefaults standardUserDefaults] stringForKey:kZhongDuanEditor];
    NSString *caoZhuoYuan = [[NSUserDefaults standardUserDefaults] stringForKey:kCaoZhuoYuanEditor];
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kHostEditor];
    NSString *port = [[NSUserDefaults standardUserDefaults] stringForKey:kPortEditor];

    NSArray *strs = nil;
    
    if (shangHuName!= nil &&shangHu != nil && zhongDuan != nil && caoZhuoYuan != nil && host!=nil && port!= nil) {
        strs = @[shangHuName,shangHu,zhongDuan,caoZhuoYuan,host,port];
    }
    
    NSArray *array = @[@"商户名：",@"商户号：",@"终端号：",@"操作号：",@"服务IP：",@"端口号："];
    for (int i=0; i<array.count; i++) {
        UIView *text = [self.view viewWithTag:i+9];
        if ([text isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)text;
            
            if (strs.count > i) {
                textField.text = [strs objectAtIndex:i];
            }
            
            textField.layer.cornerRadius = 3.0;
            textField.layer.masksToBounds = YES;
            textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
            textField.layer.borderWidth = 0.4;
            
            if (i>2)
            textField.delegate=self;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            label.backgroundColor = [UIColor clearColor];
            label.text = [array objectAtIndex:i];
            label.textColor = [UIColor darkGrayColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentRight;
            textField.leftView = label;
            textField.leftViewMode = UITextFieldViewModeAlways;
            
        }
    }
    
    self.saveButton.layer.cornerRadius = 3.0;
    self.saveButton.layer.masksToBounds = YES;
    
    
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)downloadPulicKey:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKDownloadKeyCMD()>=0)
    {
//        self.status.text=@"正在下载公钥";
    }
}

- (IBAction)downloadAID:(UIButton *)sender {
    
    if(MiniPosSDKDeviceState()<0)
        return;
    
    if(MiniPosSDKDownloadAIDParamCMD()>=0)
    {
//        self.status.text=@"正在下载AID参数";
    }
}

- (IBAction)saveSettingValue:(UIButton *)sender {
    
    if(![UIUtils isCorrectNumber:self.shangHuEditor.text] || self.shangHuEditor.text.length!=15)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的商户号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    if(![UIUtils isCorrectNumber:self.zhongDuanEditor.text] || self.zhongDuanEditor.text.length!=8)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的终端号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    if(![UIUtils isCorrectNumber:self.caoZhuoYuanEditor.text] && self.caoZhuoYuanEditor.text.length>0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的操作员号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(![UIUtils isCorrectNumber:self.portEditor.text] || self.caoZhuoYuanEditor.text.intValue<0 || self.caoZhuoYuanEditor.text.intValue>65536)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的端口号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    if (self.zhongDuanEditor.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的终端号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.hostEditor.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入服务IP" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:self.shangHuEditor.text forKey:kShangHuEditor];
    [[NSUserDefaults standardUserDefaults] setObject:self.zhongDuanEditor.text forKey:kZhongDuanEditor];
    [[NSUserDefaults standardUserDefaults] setObject:self.caoZhuoYuanEditor.text forKey:kCaoZhuoYuanEditor];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostEditor.text forKey:kHostEditor];
    [[NSUserDefaults standardUserDefaults] setObject:self.portEditor.text forKey:kPortEditor];
    [[NSUserDefaults standardUserDefaults] setObject:self.shanghuNameText.text forKey:kShangHuName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    MiniPosSDKSetPublicParam(self.shangHuEditor.text.UTF8String, self.zhongDuanEditor.text.UTF8String, self.caoZhuoYuanEditor.text.UTF8String);
    MiniPosSDKSetPostCenterParam(self.hostEditor.text.UTF8String, self.portEditor.text.intValue, 0);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
