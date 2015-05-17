//
//  BankInfoViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/14.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "BankInfoViewController.h"
#import "QRadioButton.h"
#import "AFNetworking.h"
#import "PersonInfoViewController.h"
#import "MerchantInfoViewController.h"
@interface BankInfoViewController ()

@end

@implementation BankInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile_g"];
    //创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //保存图片的路径
    self.imagePath4 = [imageDocPath stringByAppendingPathComponent:@"4.jpg"];
    
    [self _initViews];
}

- (void)_initViews{
    
    self.bankName.delegate = self;
    self.province.delegate = self;
    self.city.delegate = self;
    self.bankBranch.delegate = self;
    self.accName.delegate = self;
    self.settleAccno.delegate = self;
    

    QRadioButton *accountType_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"accountType"];
    accountType_radio1.frame = CGRectMake(130, 80, 100, 40);
    accountType_radio1.tag = 1;
    [accountType_radio1 setTitle:@"借记卡" forState:UIControlStateNormal];
    [self.view addSubview:accountType_radio1];
    [accountType_radio1 setChecked:YES];
    QRadioButton *accountType_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"accountType"];
    accountType_radio2.frame = CGRectMake(220, 80, 100, 40);
    accountType_radio2.tag = 2;
    [accountType_radio2 setTitle:@"贷记卡" forState:UIControlStateNormal];
    [self.view addSubview:accountType_radio2];
    
    QRadioButton *isPrivate_radio1 = [[QRadioButton alloc] initWithDelegate:self groupId:@"isPrivate"];
    isPrivate_radio1.frame = CGRectMake(130, 125, 100, 40);
    isPrivate_radio1.tag = 1;
    [isPrivate_radio1 setTitle:@"对私" forState:UIControlStateNormal];
    [self.view addSubview:isPrivate_radio1];
    [isPrivate_radio1 setChecked:YES];
    QRadioButton *isPrivate_radio2 = [[QRadioButton alloc] initWithDelegate:self groupId:@"isPrivate"];
    isPrivate_radio2.frame = CGRectMake(220, 125, 100, 40);
    isPrivate_radio2.tag = 0;
    [isPrivate_radio2 setTitle:@"对公" forState:UIControlStateNormal];
    [self.view addSubview:isPrivate_radio2];
    
}
- (IBAction)selectImage:(UIButton *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册获取",@"拍照",nil];
    
    
    [actionSheet showInView:self.view];
    
}
//提交审核
- (IBAction)submit:(UIButton *)sender {

    
    PersonInfoViewController *pivc = self.navigationController.viewControllers[1];
    MerchantInfoViewController *mivc = self.navigationController.viewControllers[2];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *phoneNo = [[NSUserDefaults standardUserDefaults]objectForKey:kSignUpPhoneNo];
    phoneNo = @"13202264038";
   
//    NSLog(@" pivc.password.text:%@", pivc.password.text);
//    NSLog(@" mivc.area.text:%@", mivc.area.text);
//    NSLog(@" pivc.name.text:%@", pivc.name.text);
//    NSLog(@" phoneNo:%@", phoneNo);
//    NSLog(@" pivc.ID.text:%@", pivc.ID.text);
//    NSLog(@" mivc.address.text:%@", mivc.address.text);
//    NSLog(@" self.accountType.text:%@", self.accountType.text);
//    NSLog(@" self.isPrivate.text:%@", self.isPrivate.text);
//    NSLog(@" self.bankName.text:%@",self.bankName.text);
//    NSLog(@" self.province.text:%@", self.province.text);
//    NSLog(@" self.city.text:%@", self.city.text);
//    NSLog(@" self.bankBranch.text:%@", self.bankBranch.text);
//    NSLog(@" self.settleAccno.text:%@",self.settleAccno.text);
//    NSLog(@"self.accName.text:%@",self.accName.text);
    
    NSDictionary *parameters = @{@"merType": @"6",@"passwd":pivc.password.text,@"areaCode":mivc.area.text,@"lawMan":pivc.name.text,@"phone":phoneNo,@"certType":@"1",@"certNo":pivc.ID.text,@"certExpdate":@"20150512",@"mchAddr":mivc.address.text,@"accountType":self.accountType.text,@"isPrivate":self.isPrivate.text,@"bankName":self.bankName.text,@"province":self.province.text,@"city":self.city.text,@"bankBranch":self.bankBranch.text,@"settleAccno":self.settleAccno.text,@"accName":self.accName.text,@"sn":@"G1000100130",@"settleBank":@"12345"};
    
    
    NSLog(@"parameters:%@",parameters);
    
    
    NSURL *filePath1 = [NSURL fileURLWithPath:pivc.imagePath1];
    NSURL *filePath2 = [NSURL fileURLWithPath:pivc.imagePath2];
    NSURL *filePath3 = [NSURL fileURLWithPath:pivc.imagePath3];
    NSURL *filePath4 = [NSURL fileURLWithPath:self.imagePath4];

    [self showHUD:@"正在提交"];
    
    [manager POST:@"http://122.112.12.25:8081/MposApp/registerMchInfo.action" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        [formData appendPartWithFileURL:filePath1 name:@"file1" error:nil];
        [formData appendPartWithFileURL:filePath2 name:@"file2" error:nil];
        [formData appendPartWithFileURL:filePath3 name:@"file3" error:nil];
        [formData appendPartWithFileURL:filePath4 name:@"file4" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        [self hideHUD];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //从相册选择
            [self OpenLocalPhoto];
            break;
        case 1:
            //拍照
            [self takePhoto];
            break;
        default:
            break;
    }
}

-(void)takePhoto{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)OpenLocalPhoto{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId{
    
    if ([groupId isEqualToString:@"accountType"]){
        self.accountType.text = [NSString stringWithFormat:@"%d",radio.tag];
    }else if ([groupId isEqualToString:@"isPrivate"]){
        self.isPrivate.text = [NSString stringWithFormat:@"%d",radio.tag];
    }
    
    
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo{
    
    NSLog(@"didFinishPickingImage");
    
    //当图片不为空时显示图片并保存图片
    if (image != nil) {
        //图片显示在按钮上
        [self.CardPhotoFront setBackgroundImage:image forState:UIControlStateNormal];
        
        //把图片转成NSData类型的数据来保存文件
        NSData *data;
        
        
        data = UIImageJPEGRepresentation(image, 1.0);
        
        
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        //保存
        
        [[NSFileManager defaultManager] createFileAtPath:self.imagePath4 contents:data attributes:nil];

        
        
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
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

@end
