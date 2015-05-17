//
//  WDPickView.m
//  GITestDemo
//
//  Created by 吴狄 on 15/4/17.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "WDPickView.h"

#define WDToolBarHeight 40

@interface WDPickView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,copy)NSString *plistName; //.pl
@property(nonatomic,strong)NSDictionary *plistDic; //
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,assign)NSInteger pickeviewHeight;

@property(nonatomic,copy)NSArray *state; //省一级
@property(nonatomic,copy)NSArray *city; //市一级
@property (strong, nonatomic) NSDictionary *selectedArray;

@property(strong,nonatomic) NSString *resultString;
@end

@implementation WDPickView


-(instancetype)initPickViewWithPlistName:(NSString *)plistName{
    self = [super init];
    if (self) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        
        _plistDic = [[NSDictionary alloc]initWithContentsOfFile:path];
        
        _state = [_plistDic allKeys];
        _selectedArray = _plistDic[_state[0]];
        _city = [_selectedArray allKeys];
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor lightGrayColor];
        
       
        _pickerView.frame = CGRectMake(0, WDToolBarHeight, _pickerView.frame.size.width, _pickerView.frame.size.height);
        _pickeviewHeight = _pickerView.frame.size.height;
        
        CGFloat toolViewX = 0;
        CGFloat toolViewH = _pickeviewHeight + WDToolBarHeight;
        CGFloat toolViewY = [UIScreen mainScreen].bounds.size.height - toolViewH;
        CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(toolViewX,toolViewY,toolViewW,toolViewH);
        [self addSubview:_pickerView];
        
        _toolbar = [[UIToolbar alloc]init];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
        UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
        
        _toolbar.items = @[leftItem,centerSpace,rightItem];
        _toolbar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,WDToolBarHeight);
        [self addSubview:_toolbar];
    
    }
    
    return self;
}

-(void)remove{
    [self removeFromSuperview];
}

-(void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)done{
    
    
    
    self.resultString  = [NSString stringWithFormat:@"%@,%@",self.city[[self.pickerView selectedRowInComponent:1]],self.selectedArray[self.city[[self.pickerView selectedRowInComponent:1]]]];
    NSLog(@"done:%@",self.resultString);
    
    [self.delegate toolBarDoneBtnHaveClicked:self resultString:self.resultString];
    
    [self removeFromSuperview];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        
        return self.state.count;
        
    }else{
        
        return self.city.count;
    }
}
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component ==0) {
        return self.state[row];
    }else{
        return self.city[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        self.selectedArray = self.plistDic[_state[row]];
        if (self.selectedArray.count > 0) {
            self.city = [self.selectedArray allKeys];
        }else{
            self.city = nil;
        }
        
        
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        
         self.resultString  = [NSString stringWithFormat:@"%@,%@",self.city[0],self.selectedArray[self.city[0]]];
         NSLog(@"resultString:%@",self.resultString);
    }else if(component == 1){
        
        if (self.city.count > row ) {
            
            self.resultString  = [NSString stringWithFormat:@"%@,%@",self.city[row],self.selectedArray[self.city[row]]];
            NSLog(@"resultString:%@",self.resultString);
        }
        
    }
    

  
}

@end
