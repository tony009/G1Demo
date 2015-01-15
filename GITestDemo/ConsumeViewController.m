//
//  ConsumeViewController.m
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "ConsumeViewController.h"
#import "SwipingCardViewController.h"
#import "UIUtils.h"
#import "KCalculator.h"

@interface ConsumeViewController ()<kCalculatorDelegate>
{
    float _allMoneyCount;
}
@end

@implementation ConsumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.kcalculatorView.delegate = self;
    
    self.startButton.layer.cornerRadius = 3.0;
    self.startButton.layer.masksToBounds = YES;
    
    self.numberText.layer.cornerRadius = 4.0;
    self.numberText.layer.masksToBounds = YES;
    self.numberText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.numberText.layer.borderWidth = 0.4;

    self.timeLabel.text = [UIUtils stringFromDate:[NSDate date] formate:@"yyyy-MM-dd hh:mm"];
    
//    self.kcalculatorView = [[KCalculator alloc] initWithFrame:CGRectMake(self.kcalculatorView.frame.origin.x, self.kcalculatorView.frame.origin.y
//                                                                         , self.kcalculatorView.frame.size.width, self.kcalculatorView.frame.size.height)];
    //[self.view addSubview:self.kcalculatorView];
    NSLog(@"viewDidLoad:width:%f,height:%f,x:%f,y:%f",self.kcalculatorView.frame.size.width,self.kcalculatorView.frame.size.height,self.kcalculatorView.frame.origin.x,self.kcalculatorView.frame.origin.y);

    
}
-(void)viewWillLayoutSubviews{
    NSLog(@"viewWillLayoutSubviews");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear:%f,height:%f,x:%f,y:%f",self.kcalculatorView.frame.size.width,self.kcalculatorView.frame.size.height,self.kcalculatorView.frame.origin.x,self.kcalculatorView.frame.origin.y);
    self.kcalculatorView = [[KCalculator alloc] initWithFrame:CGRectMake(self.kcalculatorView.frame.origin.x, self.kcalculatorView.frame.origin.y
                                                                             , self.kcalculatorView.frame.size.width, self.kcalculatorView.frame.size.height)];
    [self.view addSubview:self.kcalculatorView];
    self.kcalculatorView.delegate = self;
    //NSLog(@"%@",self.kcalculatorView.frame);
}


- (void)viewDidAppear:(BOOL)animated{
        NSLog(@"viewDidAppear:width:%f,height:%f,x:%f,y:%f",self.kcalculatorView.frame.size.width,self.kcalculatorView.frame.size.height,self.kcalculatorView.frame.origin.x,self.kcalculatorView.frame.origin.y);
    
    //NSLog(@"%@",self.kcalculatorView.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UIViewController *send = segue.destinationViewController;
    if ([send respondsToSelector:@selector(setType:)]) {
        [send setValue:@"刷卡消费" forKey:@"type"];
    }
    
    if ([send respondsToSelector:@selector(setCount:)]) {
        [send setValue:[NSNumber numberWithFloat:[self.numberText.text floatValue]] forKey:@"count"];
    }
    
}


- (IBAction)startAction:(UIButton *)sender {
    
    
    if (_allMoneyCount > 0) {
        
        int amount = _allMoneyCount * 100;
        char buf[20];
        
        sprintf(buf,"%012d",amount);
        
        NSLog(@"amount: %s",buf);
        
        
        _type = 1;
        MiniPosSDKSaleTradeCMD(buf, NULL);
        
        
        [self performSegueWithIdentifier:@"custPushToSwip" sender:self];
    } else {
        [self showTipView:@"请确定交易金额！"];
    }
    
}


#pragma mark - 
#pragma mark - KcalculatorView delegate 
- (void)kCalculatorDidClick:(KCalculator *)kCalculator
{
    NSLog(@" %@,%@",kCalculator.progressString,kCalculator.sumString);
    
    
    _allMoneyCount = [kCalculator.sumString floatValue];
    
    self.proText.text = kCalculator.progressString;
    if (kCalculator.sumString == nil) {
        self.numberText.text = @"0.00元";
    } else {
        self.numberText.text = [NSString stringWithFormat:@"%.2f元",[kCalculator.sumString floatValue]];
    }
}

@end
