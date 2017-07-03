//
//  ZQBelConnection.h
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/22.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef enum _peripheralState {
    /**扫描到服务*/
    didDiscoverServices  = 0,
    /**搜索特征*/
    didDiscoverCharacteristics = 1,
    /**获取特征值*/
    didUpdateValueForCharacteristic = 2,
    /**搜索到特征的Descriptors*/
    didDiscoverDescriptorsForCharacteristic = 3,
    /**获取到Descriptors的值*/
    didUpdateValueForDescriptor = 4,
    /**写入成功的回调*/
    didWriteValueForCharacteristic = 5,
} peripheralState;
@protocol ZQBelConnectionDelegate;
@interface ZQBelConnection : NSObject<CBPeripheralDelegate>
@property (nonatomic,weak)id<ZQBelConnectionDelegate>delegate;
/**外界设备*/
@property (nonatomic,strong)CBPeripheral *peripheral;
@end

@protocol ZQBelConnectionDelegate <NSObject>
/**所有的CBPeripheral代理都用这个方法，使用peripheralState枚举状态区分*/
-(void)callbackPeripheral:(CBPeripheral *)peripheral  peripheralState:(peripheralState)peripheralState service:(CBService *)service characteristic:(CBCharacteristic *)characteristic descriptor:(CBDescriptor *)descriptor  error:(NSError *)error;
@end
