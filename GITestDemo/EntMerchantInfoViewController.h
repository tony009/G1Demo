//
//  EntMerchantInfoViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/6/8.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "UIUtils.h"
#import "WDPickView.h"
#import "BaseViewController.h"
@interface EntMerchantInfoViewController :BaseViewController<UITextFieldDelegate,WDPickViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *area;
@property (strong,nonatomic)  NSString *areaCode; //地区编码
@property (strong, nonatomic) IBOutlet UITextField *address;
@property (strong, nonatomic) IBOutlet UITextField *sn;

@property (strong,nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) IBOutlet UIButton *ZuZhiJiGouDaiMaZheng;//组织机构代码证
@property (strong, nonatomic) IBOutlet UIButton *FangWuZuLinHeTongZheng;//房屋租赁合同证
@property (strong, nonatomic) IBOutlet UIButton *ShuiWuDengJiZheng; //税务登记证
@property (strong, nonatomic) IBOutlet UIButton *YingYeZhiZhaoZheng;//营业执照证



@property (strong,nonatomic) NSString *imagePath6; //组织机构代码证路径
@property (strong,nonatomic) NSString *imagePath7; //房屋租赁合同路径
@property (strong,nonatomic) NSString *imagePath8; //税务登记证路径
@property (strong,nonatomic) NSString *imagePath9; //营业执照路径


@end
