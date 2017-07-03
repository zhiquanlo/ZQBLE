//
//  interaction.m
//  蓝牙
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "interaction.h"

@interface interaction ()
{
    UIButton *notice;//通知按钮
}
@end

@implementation interaction

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"跟设备交互";
    
    notice = [UIButton buttonWithType:UIButtonTypeCustom];
    notice.frame = CGRectMake(0, 64, self.view.frame.size.width, 50);
    [notice setTitle:@"注册通知订阅" forState:UIControlStateNormal];
    [notice setTitle:@"取消通知订阅" forState:UIControlStateSelected];
    [notice addTarget:self action:@selector(noticeClick) forControlEvents:UIControlEventTouchUpInside];
    notice.backgroundColor = [UIColor redColor];
    [self.view addSubview:notice];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 114, self.view.frame.size.width, 50);
    [btn setTitle:@"向设备写一个值" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view.
}
- (void)noticeClick
{
    notice.selected = notice.selected ? NO:YES;
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [self.bel setNotify:self.peripheral isSubscribe:notice.selected characteristi:self.characteristic];
}
- (void)btnClick
{
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast= 0x01,
     CBCharacteristicPropertyRead= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse= 0x04,
     CBCharacteristicPropertyWrite= 0x08,
     CBCharacteristicPropertyNotify= 0x10,
     CBCharacteristicPropertyIndicate= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites= 0x40,
     CBCharacteristicPropertyExtendedProperties= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)= 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)self.characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(self.characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        Byte b[] = {0XFF,0X01,0X01,0XAA,0X00,0X00,0X00,0XAC};
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        
        [self.bel writeValue:self.peripheral value:[self hexString:@"哈哈"] characteristi:self.characteristic isReturn:YES];
    }else{
        NSLog(@"该字段不可写！");
    }
    
}
-(NSData *)hexString:(NSString *)hexString {
    int j=0;
    Byte bytes[20];
    ///3ds key的Byte 数组， 128位
    for(int i=0; i<[hexString length]; i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:20];
    
    return newData;
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
