//
//  ZQBelScanning.h
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
@protocol ZQBelScanningDelegate;

typedef enum _centralManagerState {
    /**查看设备状态*/
    centralManagerDidUpdateState  = 0,
    /**搜索到外界设备*/
    didDiscoverPeripheral = 1,
    /**连接失败*/
    didFailToConnectPeripheral = 2,
    /**断开连接*/
    didDisconnectPeripheral = 3,
    /**连接成功*/
    didConnectPeripheral = 4,
} centralManagerState;

@interface ZQBelScanning : NSObject<CBCentralManagerDelegate>
/**中心设备也就是手机的蓝牙设备*/
@property (nonatomic,strong)CBCentralManager *manager;
@property (nonatomic,weak)id<ZQBelScanningDelegate>delegate;
/**调起扫描设备*/
-(void)scanningEquipment;
@end

@protocol ZQBelScanningDelegate <NSObject>
/**所有的CBCentralManager代理都用这个方法，使用centralManagerState枚举状态区分*/
-(void)centralManagerState:(CBCentralManager *)central  centralManagerState:(centralManagerState)centralManagerState didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI  error:(NSError *)error;
@end
