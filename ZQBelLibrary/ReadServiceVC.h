//
//  ReadServiceVC.h
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/22.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZQBle.h"
@interface ReadServiceVC : UIViewController
/**外界设备*/
@property (nonatomic,strong)CBPeripheral *peripheral;
@property (nonatomic,strong)ZQBle *bel;
@end
