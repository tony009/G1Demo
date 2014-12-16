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
        [send setValue:@"消费刷卡" forKey:@"type"];
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
