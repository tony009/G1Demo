//
//  PrintNoteViewController.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import "BaseViewController.h"

@class PPSSignatureView;
@interface PrintNoteViewController : BaseViewController <NSStreamDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (strong, nonatomic) IBOutlet UIView *printView;

@property (nonatomic, copy) NSString *type;  //交易类型（交易，撤销）
@property (nonatomic, assign) float count; //金额

@property (strong, nonatomic) IBOutlet UILabel *topLabel1;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutlet UILabel *topLastLabel;

@property (strong, nonatomic) IBOutlet UIButton *signatureBt;

@property (strong, nonatomic) IBOutlet UILabel *tipLabel;

@property (strong, nonatomic) IBOutlet UIView *ppsSignView;

@property (strong, nonatomic) IBOutlet PPSSignatureView *signView;

@property (strong, nonatomic) IBOutlet UIImageView *signImgView;

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;

@property (strong,nonatomic) dispatch_queue_t serialQueue;

- (IBAction)signatureAction:(UIButton *)sender;


- (IBAction)resignAction:(id)sender;


@end
