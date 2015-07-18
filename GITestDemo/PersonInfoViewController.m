//
//  PersonInfoViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/12.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "UIUtils.h"
@interface PersonInfoViewController ()
{
    UIButton *_lastPressedBtn;
    NSString *_imageDocPath;

}
@end

@implementation PersonInfoViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initViews];
    
}

- (void)_initViews{



    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 60, 44)];
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(120, 0, 60, 44)];
    [label1 setText:@"个人信息"];
    [label2 setText:@"商户信息"];
    [label3 setText:@"银行账号"];
    [label1 setFont:[UIFont systemFontOfSize:14]];
    [label2 setFont:[UIFont systemFontOfSize:14]];
    [label3 setFont:[UIFont systemFontOfSize:14]];
    [titleView addSubview:label1];
    [titleView addSubview:label2];
    [titleView addSubview:label3];
    
    label1.textColor = [UIColor blackColor];
    label2.textColor = [UIColor grayColor];
    label3.textColor = [UIColor grayColor];
    
    self.navigationItem.titleView = titleView;
    
    
    self.password.delegate = self;
    self.name.delegate = self;
    self.ID.delegate = self;
    
    
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    _imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile_g"];
    //创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:_imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];

    
    self.imagePath1 = @"";
    self.imagePath2 = @"";
    self.imagePath3 = @"";
    self.imagePath10 = @"";
}


- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeImage:(UIButton*)sender {
    
    _lastPressedBtn = sender;
    
    self.actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册获取",@"拍照",nil];
    
    
    [self.actionSheet showInView:self.view];

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

- (IBAction)next:(id)sender {
    
    if (DEBUG) {
       [self performSegueWithIdentifier:@"NEXT" sender:nil];
        return;
    }
    
    //校验信息
    
    if (![UIUtils isCorrectPassword:self.password.text]) {
        [self showTipView:@"请输入正确的密码"];
        return;
    }else if (![self.rePassword.text isEqualToString:self.password.text]) {
        [self showTipView:@"2次密码不一致，请重新输入"];
        return;
    }else if ([UIUtils isEmptyString:self.name.text]||[self.name.text length] > 10) {
        [self showTipView:@"请输入正确的姓名"];
        return;
    }else if (![UIUtils isCorrectID:self.ID.text]) {
        [self showTipView:@"请输入正确的身份证号码"];
        return;
    }else if ([UIUtils isEmptyString:self.certExpdate.text]) {
        [self showTipView:@"请输入正确的身份证有效期"];
        return;
    }else if ([UIUtils isEmptyString:self.imagePath1]){
        [self showTipView:@"请选择身份证正面照"];
        return;
    }else if ([UIUtils isEmptyString:self.imagePath2]){
        [self showTipView:@"请选择身份证反面照"];
        return;
    }else if ([UIUtils isEmptyString:self.imagePath3]){
        [self showTipView:@"请选择法人持身份证照"];
        return;
    }else if ([UIUtils isEmptyString:self.imagePath10]){
        [self showTipView:@"请选择现场照片"];
        return;
    }
    
    //跳转
    [self performSegueWithIdentifier:@"NEXT" sender:nil];
    
    
    
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
        [_lastPressedBtn setBackgroundImage:image forState:UIControlStateNormal];
        
        //把图片转成NSData类型的数据来保存文件
        NSData *data;
        //判断图片是不是png格式的文件
  
        data = UIImageJPEGRepresentation(image, 1.0);
      

        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        
        //保存
        if (_lastPressedBtn == self.IDPhotoFront) {
            self.imagePath1 = [_imageDocPath stringByAppendingPathComponent:@"1.jpg"];
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath1 contents:data attributes:nil];
        }else if (_lastPressedBtn == self.IDPhotoBack){
            self.imagePath2 = [_imageDocPath stringByAppendingPathComponent:@"2.jpg"];
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath2 contents:data attributes:nil];
        }else if (_lastPressedBtn == self.IDPhotoAndPerson){
            self.imagePath3 = [_imageDocPath stringByAppendingPathComponent:@"3.jpg"];
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath3 contents:data attributes:nil];
        }else if (_lastPressedBtn == self.XianChangZhaoPian){
            self.imagePath10 = [_imageDocPath stringByAppendingPathComponent:@"10.jpg"];
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath10 contents:data attributes:nil];
        }
        
       
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
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
