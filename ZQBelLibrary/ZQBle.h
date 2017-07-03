//
//  ZQBle.h
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZQBelScanning.h"
#import "ZQBelConnection.h"
@protocol ZQBleDelegate;

@interface ZQBle : NSObject<ZQBelScanningDelegate,ZQBelConnectionDelegate>
@property (nonatomic,weak)id<ZQBleDelegate>delegate;
/**搜索类*/
@property (nonatomic,strong)ZQBelScanning *belScanning;
/**连接类*/
@property (nonatomic,strong)ZQBelConnection *belConnection;
/**所有的CBPeripheral代理都用这个方法，使用peripheralState枚举状态区分*/
@property (nonatomic,copy)void (^callbackPeripheralDelegate)(CBPeripheral *peripheral,peripheralState peripheralState,CBService *service,CBCharacteristic *characteristic,CBDescriptor *descriptor,NSError *error);
@property (nonatomic,strong)NSMutableArray *peripherals;
/**调起扫描设备*/
-(void)scanningEquipment;
/**连接设备*/
- (void)connectPeripheral:(CBPeripheral *)peripheral;
/**停止扫描*/
-(void)stopScan;
/**断开连接*/
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;
/**断开所有连接*/
- (void)cancelAllPeripheralConnection;
/**设置通知订阅*/
- (void)setNotify:(CBPeripheral *)peripheral isSubscribe:(BOOL)isSubscribe  characteristi:(CBCharacteristic *)characteristi;
/**向蓝牙写入数据isReturnYES成功会在void (^callbackPeripheralDelegate)(CBPeripheral *peripheral,peripheralState peripheralState,CBService *service,CBCharacteristic *characteristic,CBDescriptor *descriptor,NSError *error)返回*/
- (void)writeValue:(CBPeripheral *)peripheral value:(NSData *)value characteristi:(CBCharacteristic *)characteristi isReturn:(BOOL)isReturn;
@end

@protocol ZQBleDelegate <NSObject>
/**所有的CBCentralManager代理都用这个方法，使用centralManagerState枚举状态区分*/
-(void)centralManagerState:(CBCentralManager *)central  centralManagerState:(centralManagerState)centralManagerState didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI  error:(NSError *)error;

@end
