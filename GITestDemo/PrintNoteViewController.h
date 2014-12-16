//
//  PrintNoteViewController.h
//  GITestDemo
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "BaseViewController.h"
@class PPSSignatureView;
@interface PrintNoteViewController : BaseViewController


@property (strong, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (strong, nonatomic) IBOutlet UIView *printView;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) float count;

@property (strong, nonatomic) IBOutlet UILabel *topLabel1;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutlet UILabel *topLastLabel;

@property (strong, nonatomic) IBOutlet UIButton *signatureBt;

@property (strong, nonatomic) IBOutlet UILabel *tipLabel;

@property (strong, nonatomic) IBOutlet UIView *ppsSignView;

@property (strong, nonatomic) IBOutlet PPSSignatureView *signView;

@property (strong, nonatomic) IBOutlet UIImageView *signImgView;



- (IBAction)signatureAction:(UIButton *)sender;


- (IBAction)resignAction:(id)sender;


@end
