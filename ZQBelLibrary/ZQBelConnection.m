//
//  ZQBelConnection.m
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/22.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ZQBelConnection.h"

@implementation ZQBelConnection 

//扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //  NSLog(@">>>扫描到服务：%@",peripheral.services);
    if (error)
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didDiscoverServices service:nil characteristic:nil descriptor:nil error:error];
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}
//4.2获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didDiscoverCharacteristics service:service characteristic:nil descriptor:nil error:error];
    }
   
    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
    
}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didUpdateValueForCharacteristic service:nil characteristic:characteristic descriptor:nil error:error];
    }
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didDiscoverDescriptorsForCharacteristic service:nil characteristic:characteristic descriptor:nil error:error];
    }
    
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didUpdateValueForDescriptor service:nil characteristic:nil descriptor:descriptor error:error];
    }
}
/**写值成功*/
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(callbackPeripheral:peripheralState:service:characteristic:descriptor:error:)]) {
        [self.delegate callbackPeripheral:peripheral peripheralState:didUpdateValueForDescriptor service:nil characteristic:characteristic descriptor:nil error:error];
    }
    NSLog(@"写入%@成功",characteristic);
}
@end
