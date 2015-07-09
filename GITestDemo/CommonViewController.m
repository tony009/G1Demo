//
//  CommonViewController.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/29.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "CommonViewController.h"
#import "AppDelegate.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface CommonViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *_array;
    BOOL isOpen;
    NSInteger selectedIndex; //被选中的索引
}
@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedIndex = -1;
    isOpen = false;
    _array = [[NSMutableArray alloc]initWithArray:@[@"设备信息",@"交易规则",@"固件升级",@"使用帮助",@"关于我们"]];
    
    self.phoneNo.text = [[NSUserDefaults standardUserDefaults] stringForKey:kLoginPhoneNo];
    
    self.phoneNoTextField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openOrCloseLeftList:(id)sender
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.LeftSlideVC.closed)
    {
        [tempAppDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [tempAppDelegate.LeftSlideVC closeLeftView];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell ;
    
    if (isOpen && selectedIndex > -1&& selectedIndex + 1 == indexPath.row) {
        
        static NSString *Identifier = @"Identifier1";
        cell= [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        
        cell.textLabel.text = _array[indexPath.row];
        
        
        
    }else{
        
        static NSString *Identifier = @"Identifier";
        cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        
        cell.textLabel.text = _array[indexPath.row];
        cell.textLabel.textColor = [UIColor blueColor];
        
    }

    //cell.accessoryView =

    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(selectedIndex >-1 && selectedIndex + 1== indexPath.row){
        
        return 90;
    }else{
        
        return 40;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(isOpen ){
         //选中打开的，就关闭
        if (indexPath.row == selectedIndex) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:selectedIndex+1 inSection:0];
            [_array removeObjectAtIndex:ip.row];
            selectedIndex = -1;
            isOpen = false;
            [tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
 
        }else if(indexPath.row != selectedIndex+1){
            //选中其它的，先关闭，再打开
            NSIndexPath *rmIP = [NSIndexPath indexPathForRow:selectedIndex+1 inSection:0];
            NSIndexPath *inIP = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            
            if (indexPath.row > selectedIndex) {
                 inIP = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            }
            
           
            [_array removeObjectAtIndex:rmIP.row];
            [tableView deleteRowsAtIndexPaths:@[rmIP] withRowAnimation:UITableViewRowAnimationFade];
            
            NSString *str = [NSString stringWithFormat:@"%ld",(long)inIP.row-1];
            [_array insertObject:str atIndex:inIP.row];
            selectedIndex = inIP.row - 1;
            isOpen = true;
            [tableView insertRowsAtIndexPaths:@[inIP] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
        
    }else{
         //未打开，就打开
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            NSArray *array = @[ip];
            
            selectedIndex = indexPath.row;
            
            NSString *str = [NSString stringWithFormat:@"%ld",(long)selectedIndex];
            
            [_array insertObject:str atIndex:ip.row];
            
        
            isOpen = true;
            [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
     
    }
    
    
}

#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSLog(@"textFieldShouldBeginEditing");
    

    [self setViewMovedUp:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSLog(@"textFieldShouldReturn");

    [self setViewMovedUp:NO];
    [textField resignFirstResponder];
    return YES;
}


- (void)setViewMovedUp:(BOOL)movedUp{
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = self.view.frame;
        if (movedUp) {
            if (rect.origin.y >=0) {
                rect.origin.y -= kOFFSET_FOR_KEYBOARD;
                
            }
        }else{
            if (rect.origin.y <0) {
                rect.origin.y += kOFFSET_FOR_KEYBOARD;
            }
        }
        
        self.view.frame = rect;
    }];
    

}

@end
