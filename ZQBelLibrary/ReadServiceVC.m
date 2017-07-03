//
//  ReadServiceVC.m
//  ZQBelLibrary
//
//  Created by 李志权 on 2017/6/22.
//  Copyright © 2017年 李志权. All rights reserved.
//

#import "ReadServiceVC.h"
#import "interaction.h"
@interface ReadServiceVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableDictionary *dicData;

@end

@implementation ReadServiceVC
- (void)disconnect
{
    [self.bel cancelPeripheralConnection:self.peripheral];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"读取设备信息";
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"断开连接" style:UIBarButtonItemStylePlain target:self action: @selector(disconnect)];
    [self.view addSubview:self.tableView];
    __weak ReadServiceVC *weakSelf = self;
    self.bel.callbackPeripheralDelegate = ^(CBPeripheral *peripheral,peripheralState peripheralState,CBService *service,CBCharacteristic *characteristic,CBDescriptor *descriptor,NSError *error)
    {
        switch (peripheralState) {
            case didDiscoverServices:
                NSLog(@"扫描到服务");
                break;
            case didDiscoverCharacteristics:
            {
                NSLog(@"扫描到特征");
                NSMutableArray *array = [NSMutableArray array];
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
                    [array addObject:characteristic];
                }
                [weakSelf.dicData setObject:array forKey:service.UUID.UUIDString];
                [weakSelf.tableView reloadData];
                
                break;
            }
            case didUpdateValueForCharacteristic:
                NSLog(@"获取特征值");
                break;
            case didDiscoverDescriptorsForCharacteristic:
                NSLog(@"搜索到特征的Descriptors");
                break;
            case didUpdateValueForDescriptor:
                NSLog(@"获取到Descriptors的值");
                break;
            case didWriteValueForCharacteristic:
                NSLog(@"写入成功的回调");
                break;
            default:
                break;
        }
    };
    // Do any additional setup after loading the view from its nib.
}
- (NSMutableDictionary *)dicData
{
    if (!_dicData) {
        _dicData = [NSMutableDictionary dictionary];
    }
    return _dicData;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        
    }
    return _tableView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dicData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keyArr = [self.dicData allKeys];
    NSArray *array = self.dicData[keyArr[section]];
    return array.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keyArr = [self.dicData allKeys];
    return keyArr[section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSArray *keyArr = [self.dicData allKeys];
    NSArray *array =self.dicData[keyArr[indexPath.section]];
    CBCharacteristic *characteristic = array[indexPath.row];
    cell.textLabel.text = characteristic.UUID.UUIDString;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keyArr = [self.dicData allKeys];
    NSArray *array =self.dicData[keyArr[indexPath.section]];
    CBCharacteristic *characteristic = array[indexPath.row];
    interaction *VC = [[interaction alloc]init];
    VC.characteristic = characteristic;
    VC.peripheral = self.peripheral;
    VC.bel = self.bel;
    [self.navigationController  pushViewController:VC animated:YES];
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
