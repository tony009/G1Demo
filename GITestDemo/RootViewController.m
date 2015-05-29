//
//  RootViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "RootViewController.h"
#import "LPPopup.h"
@interface RootViewController ()

@end

@implementation RootViewController
{
    UITapGestureRecognizer *_tapGestureRecognizer;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    
    
    self.view.backgroundColor =rgb(229, 229, 229, 1);
    
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 50);
    [backButton setImage:[UIImage imageNamed:@"箭头.png"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAction)];
    
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewWillAppear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    NSLog(@"keyboardWillShow");
    
}
-(void)keyboardWillHide:(NSNotification *)notification{
    
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
}



- (void)showHUD:(NSString *)title{
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = title;
    
}

- (void)showTipView:(NSString *)tip
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LPPopup *popup = [LPPopup popupWithText:tip];
        popup.popupColor = [UIColor blackColor];
        popup.textColor = [UIColor whiteColor];
        [popup showInView:self.view
            centerAtPoint:self.view.center
                 duration:kLPPopupDefaultWaitDuration
               completion:nil];
    });


}

- (void)hideHUD{
    if (_hud) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hide:YES];
        });
    }
  
    
}


//
- (void)dismissAction{
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
