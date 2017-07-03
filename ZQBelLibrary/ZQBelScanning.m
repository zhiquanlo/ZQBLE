//
//  ZQBelScanning.m
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ZQBelScanning.h"
@implementation ZQBelScanning
-(instancetype)init
{
    if (self = [super init]) {
        
        /*
         设置主设备的委托,CBCentralManagerDelegate
         必须实现的：
         - (void)centralManagerDidUpdateState:(CBCentralManager *)central;//主设备状态改变的委托，在初始化CBCentralManager的适合会打开设备，只有当设备正确打开后才能使用
         其他选择实现的委托中比较重要的：
         - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设的委托
         - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
         - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
         - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
         */
        //初始化并设置委托和线程队列，最好一个线程的参数可以为nil，默认会就main线程
        
         self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}
/**调起扫描设备*/
-(void)scanningEquipment
{
   // 蓝牙未打开
    if (self.manager.state == CBCentralManagerStatePoweredOff) {
        [self PromptBluetoothIsNotOpen];
    }
    else
    {
        [self.manager scanForPeripheralsWithServices:nil options:nil];
    }
   

}
- (void)PromptBluetoothIsNotOpen{

    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"打开蓝牙来连接到配件" preferredStyle:(UIAlertControllerStyleAlert)];
    
    // 是否跳转到蓝牙界面
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Bluetooth"]];
       
    }];
    // 创建按钮
    // 注意取消按钮只能添加一个
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    // 添加按钮 将按钮添加到UIAlertController对象上
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // 将UIAlertController模态出来 相当于UIAlertView show 的方法
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
   
    
}

//###2 扫描外设（discover），扫描外设的方法我们放在centralManager成功打开的委托中，因为只有设备成功打开，才能开始扫描，否则会报错。
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
            //状态未知
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown未知状态");
            break;
            //连接断开 即将重置
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting连接断开，即将重置");
            break;
            //该平台不支持蓝牙
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported，该设备部支持蓝牙");
            break;
            //未授权蓝牙使用 hovertree.com
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized，蓝牙未授权");
            break;
            //蓝牙关闭
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff，蓝牙关闭");
            [self PromptBluetoothIsNotOpen];
            break;
            //蓝牙正常开启
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn，蓝牙正常");
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
    /**设备状态异常*/
    if (central.state != CBCentralManagerStatePoweredOn) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
            
            [self.delegate centralManagerState:central centralManagerState:centralManagerDidUpdateState didDiscoverPeripheral:nil advertisementData:nil RSSI:nil error:nil];
        }
    }
    
}
//###3 连接外设(connect)
//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
        
        [self.delegate centralManagerState:central centralManagerState:didDiscoverPeripheral didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI error:nil];
    }
}
//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
        
        [self.delegate centralManagerState:central centralManagerState:didFailToConnectPeripheral didDiscoverPeripheral:peripheral advertisementData:nil RSSI:nil error:error];
    }
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
        
        [self.delegate centralManagerState:central centralManagerState:didDisconnectPeripheral didDiscoverPeripheral:peripheral advertisementData:nil RSSI:nil error:error];
    }
    
}
//###4 扫描外设中的服务和特征(discover)

//设备连接成功后，就可以扫描设备的服务了，同样是通过委托形式，扫描到结果后会进入委托方法。但是这个委托已经不再是主设备的委托（CBCentralManagerDelegate），而是外设的委托（CBPeripheralDelegate）,这个委托包含了主设备与外设交互的许多 回叫方法，包括获取services，获取characteristics，获取characteristics的值，获取characteristics的Descriptor，和Descriptor的值，写数据，读rssi，用通知的方式订阅数据等等。
//4.1获取外设的services
//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController            [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [peripheral discoverServices:nil];

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(centralManagerState:centralManagerState:didDiscoverPeripheral:advertisementData:RSSI:error:)]) {
        
        [self.delegate centralManagerState:central centralManagerState:didConnectPeripheral didDiscoverPeripheral:peripheral advertisementData:nil RSSI:nil error:nil];
    }
}
@end
