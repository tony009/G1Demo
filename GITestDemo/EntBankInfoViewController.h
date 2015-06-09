//
//  EntBankInfoViewController.h
//  GITestDemo
//
//  Created by 吴狄 on 15/6/9.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface EntBankInfoViewController :RootViewController<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *CardPhotoFront; //银行卡正面照
@property (strong,nonatomic) NSString *imagePath4 ;//银行卡正面照路径



@property (strong, nonatomic) IBOutlet UITextField *accountType; //银行卡类型

@property (strong, nonatomic) IBOutlet UITextField *isPrivate;//账号标识

@property (strong, nonatomic) IBOutlet UITextField *bankName;//开户行全称
@property (strong, nonatomic) IBOutlet UITextField *province;//所在省

@property (strong, nonatomic) IBOutlet UITextField *city; //所在市
@property (strong, nonatomic) IBOutlet UITextField *bankBranch;//支行名称
@property (strong, nonatomic) IBOutlet UITextField *settleAccno; //开户账号
@property (strong, nonatomic) IBOutlet UITextField *accName; //开户姓名
@property (weak, nonatomic) IBOutlet UITextField *settleBank; //银行联行号

@end
