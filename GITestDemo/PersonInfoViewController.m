//
//  PersonInfoViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/5/12.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "PersonInfoViewController.h"

@interface PersonInfoViewController ()
{
    UIButton *_lastPressedBtn;

}
@end

@implementation PersonInfoViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initViews];
    
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile_g"];
    //创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //保存图片的路径
    self.imagePath1 = [imageDocPath stringByAppendingPathComponent:@"1.jpg"];
    self.imagePath2 = [imageDocPath stringByAppendingPathComponent:@"2.jpg"];
    self.imagePath3 = [imageDocPath stringByAppendingPathComponent:@"3.jpg"];
}

- (void)_initViews{

    
    self.password.delegate = self;
    self.name.delegate = self;
    self.ID.delegate = self;
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
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath1 contents:data attributes:nil];
        }else if (_lastPressedBtn == self.IDPhotoBack){
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath2 contents:data attributes:nil];
        }else if (_lastPressedBtn == self.IDPhotoAndPerson){
            [[NSFileManager defaultManager] createFileAtPath:self.imagePath3 contents:data attributes:nil];
        }
        
       
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    
}

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
