//
//  ViewController.m
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/21.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ViewController.h"
#import "ZQBle.h"
#import "ReadServiceVC.h"
@interface ViewController ()<ZQBleDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)ZQBle *bel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *arrayData;
@property (nonatomic,strong)NSMutableDictionary *characteristicsDic;
@end

@implementation ViewController
/**断开所有连接*/
- (IBAction)disconnectAll:(id)sender {
    [self.bel cancelAllPeripheralConnection];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bel = [[ZQBle alloc]init];
    self.bel.delegate = self;
    
    self.arrayData = [NSMutableArray array];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.numberOfLines = 0;
    }
    if (self.arrayData && self.arrayData.count>indexPath.row) {
        NSDictionary *dic = self.arrayData[indexPath.row];
        CBPeripheral *peripheral = dic[@"CBPeripheral"];
        NSDictionary *advertisementData = dic[@"advertisementData"];
        if (peripheral.name && peripheral.name.length) {
            cell.textLabel.text = peripheral.name;
        }else if (advertisementData[@"kCBAdvDataLocalName"])
        {
            cell.textLabel.text =[NSString stringWithFormat:@"%@",advertisementData[@"kCBAdvDataLocalName"]];
        }
        if (cell.textLabel.text.length) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",cell.textLabel.text,advertisementData[@"kCBAdvDataManufacturerData"]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",advertisementData[@"kCBAdvDataManufacturerData"]];
        }
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",self.arrayData[indexPath.row]);
    CBPeripheral *pripheral = self.arrayData[indexPath.row][@"peripheral"];
    [self.bel stopScan];
    [self.bel connectPeripheral:pripheral];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**所有的CBCentralManager代理都用这个方法，使用centralManagerState枚举状态区分*/
- (void)centralManagerState:(CBCentralManager *)central centralManagerState:(centralManagerState)centralManagerState didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI error:(NSError *)error
{
    switch (centralManagerState) {
        case centralManagerDidUpdateState:
            NSLog(@"状态出现异常");
            [self.arrayData removeAllObjects];
            
            break;
        case didDiscoverPeripheral:
            NSLog(@"搜索到设备%@",peripheral);
            if (peripheral.name || advertisementData[@"kCBAdvDataLocalName"] || advertisementData[@"kCBAdvDataManufacturerData"]) {
                
                [self.arrayData addObject:@{@"peripheral":peripheral,@"advertisementData":advertisementData,@"RSSI":RSSI}];
                [self.tableView reloadData];
            }
            break;
        case didFailToConnectPeripheral:
            NSLog(@"连接失败%@",error);
            break;
        case didDisconnectPeripheral:
            NSLog(@"连接端开连接%@%@",peripheral.name,error);
            break;
        case didConnectPeripheral:
        {
            NSLog(@"连接成功");
            ReadServiceVC *VC = [[ReadServiceVC alloc]init];
            VC.bel = self.bel;
            VC.peripheral = peripheral;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        default:
            break;
    }
}

/**搜索*/
- (IBAction)scanningEquipment:(id)sender {
    [self.arrayData removeAllObjects];
    [self.bel scanningEquipment];
}

@end
