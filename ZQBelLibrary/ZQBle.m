//
//  ZQBle.m
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ZQBle.h"

@implementation ZQBle
- (instancetype)init
{
    if (self = [super init]) {
        self.belScanning = [[ZQBelScanning alloc] init];
        self.belScanning.delegate = self;
        self.peripherals = [NSMutableArray array];
    }
    return self;
}
/**调起扫描设备*/
-(void)scanningEquipment{
    [self.belScanning scanningEquipment];
}
/**停止扫描*/
-(void)stopScan
{
    [self.belScanning.manager stopScan];
}
/**断开连接*/
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [self.belScanning.manager cancelPeripheralConnection:peripheral];
        [self.peripherals removeObject:peripheral];
    }
    
}
/**断开所有连接*/
- (void)cancelAllPeripheralConnection
{
    for (int a = 0; a<self.peripherals.count; a++) {
        [self.belScanning.manager cancelPeripheralConnection:self.peripherals[a]];
    }
}
/**连接设备*/
- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [self.belScanning.manager connectPeripheral:peripheral options:nil];
    
    BOOL isAre = NO;
    for (CBPeripheral *Tperipheral in self.peripherals) {
        if (Tperipheral== peripheral) {
            isAre = YES;
        }
    }
    if (!isAre) {
        [self.peripherals addObject:peripheral];
    }
    
}
/**设置通知订阅*/
- (void)setNotify:(CBPeripheral *)peripheral isSubscribe:(BOOL)isSubscribe  characteristi:(CBCharacteristic *)characteristi
{
    [peripheral setNotifyValue:isSubscribe forCharacteristic:characteristi];
}
/**向蓝牙写入数据isReturnYES成功会在void (^callbackPeripheralDelegate)(CBPeripheral *peripheral,peripheralState peripheralState,CBService *service,CBCharacteristic *characteristic,CBDescriptor *descriptor,NSError *error)返回*/
- (void)writeValue:(CBPeripheral *)peripheral value:(NSData *)value characteristi:(CBCharacteristic *)characteristi isReturn:(BOOL)isReturn
{
    CBCharacteristicWriteType type = isReturn ?CBCharacteristicWriteWithResponse :CBCharacteristicWriteWithoutResponse;
     [peripheral writeValue:value forCharacteristic:characteristi type:type];
}
/**所有的CBCentralManager代理都用这个方法，使用centralManagerState枚举状态区分*/
-(void)centralManagerState:(CBCentralManager *)central  centralManagerState:(centralManagerState)centralManagerState didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI  error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
        
        [self.delegate centralManagerState:central centralManagerState:centralManagerState didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI error:error];
        
        if (centralManagerState == didConnectPeripheral) {
            self.belConnection = [[ZQBelConnection alloc]init];
            self.belConnection.delegate = self;
            self.belConnection.peripheral = peripheral;
            self.belConnection.peripheral.delegate = self.belConnection;
        }
    }
}
/**所有的CBPeripheral代理都用这个方法，使用peripheralState枚举状态区分*/
-(void)callbackPeripheral:(CBPeripheral *)peripheral  peripheralState:(peripheralState)peripheralState service:(CBService *)service characteristic:(CBCharacteristic *)characteristic descriptor:(CBDescriptor *)descriptor  error:(NSError *)error
{
    if (self.callbackPeripheralDelegate) {
        self.callbackPeripheralDelegate(peripheral, peripheralState, service, characteristic, descriptor, error);
    }
}
@end
