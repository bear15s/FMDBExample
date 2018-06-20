//
//  ViewController.m
//  FMDBExample
//
//  Created by zbmy on 2018/6/19.
//  Copyright © 2018年 HakoWaii. All rights reserved.
//

#import "ViewController.h"
#import <FMDB.h>
#import "Student.h"
#import "StudentTBCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UILabel *idLbl;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (strong,nonatomic)NSMutableArray* stuDataList;
@end

@implementation ViewController{
    FMDatabase * _myDB;
    NSString* _dbPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataTableView registerClass:[StudentTBCell class] forCellReuseIdentifier:@"StudentTBCell"];
    self.stuDataList = [NSMutableArray array];
    // Do any additional setup after loading the view, typically from a nib.
    [self createTalbe];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    Student * stu = [Student new];
    stu.stu_name = self.nameTextField.text;
    stu.stu_sex = self.sexTextField.text;
    stu.stu_age = self.ageTextField.text.intValue;
    [self insertDataWithStudent:stu];
    [self insertMutiData];
}

- (IBAction)update:(id)sender {
    [self updateData];
}

- (IBAction)load:(id)sender {
    [self queryData];
    [self.dataTableView reloadData];
}

- (IBAction)delete:(id)sender {
    [self deleteDataWithPrimarykey:self.idLbl.text.intValue];
}

- (void)createTalbe{
    
    NSString* docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    _dbPath = [docPath stringByAppendingPathComponent:@"student.sqlite"];
    
    _myDB = [FMDatabase databaseWithPath:_dbPath];
    if([_myDB open]){
        NSString* createTbSql = @"create table if not exists t_student(id integer primary key autoincrement not null, name text not null, age integer not null, sex text not null)";
        //关于什么时候update，什么时候query
        //只有select是查询，其他操作都是更新
        
        BOOL result = [_myDB executeUpdate:createTbSql];
        if(result){
            NSLog(@"创表成功 dbPath = %@",_dbPath);
        }else{
            NSLog(@"创表失败");
        }
    }
    [_myDB close];
}


- (void)insertDataWithStudent:(Student*)stu
{
    NSString* insertSql = @"insert into t_student(name,age,sex) values(?,?,?)";
    if([_myDB open]){
        BOOL result = [_myDB executeUpdate:insertSql,stu.stu_name,@(stu.stu_age),stu.stu_sex];
        if(result){
            NSLog(@"插入数据成功 name = %@",stu.stu_name);
        }else{
            NSLog(@"插入数据失败 name = %@",stu.stu_name);
        }
    }
    [_myDB close];
}

- (void)deleteDataWithPrimarykey:(int)pKey{
    if([_myDB open]){
        if([self checkExistWithPrimaryKey:pKey]){
            BOOL result = [_myDB executeUpdate:@"delete from t_student where id = ?",@(pKey)];
            if(result){
                NSLog(@"删除数据成功 id = %d",pKey);
            }else{
                NSLog(@"删除数据失败 id = %d",pKey);
            }
        }
    }
    [_myDB close];
}

- (void)updateData{
    if([_myDB open]){
        if([self checkExistWithPrimaryKey:self.idLbl.text.intValue]){
            BOOL result = [_myDB executeUpdate:@"update t_student set name = ?,age = ?,sex = ? where id = ?",self.nameTextField.text,@(self.ageTextField.text.intValue),self.sexTextField.text,@(self.idLbl.text.intValue)];
            if(result){
                NSLog(@"修改数据成功");
            }else{
                NSLog(@"修改数据失败");
            }
        }else{
            NSLog(@"不存在本id数据");
        }
    }
}

- (BOOL)checkExistWithPrimaryKey:(int)key{
    BOOL result = NO;
//    if([_myDB open]){
        FMResultSet * resultSet = [_myDB executeQuery:@"select * from t_student where id = ?",@(key)];
        if(resultSet){
            while ([resultSet next]) {
                if([resultSet intForColumn:@"id"] == key){
                    result = YES;
                    break;
                }
            }
        }else{
            NSLog(@"query fail");
        }
//    }
//    [_myDB close];
    return result;
}

- (void)queryData{
    [_myDB open];
    FMResultSet * resultSet = [_myDB executeQuery:@"select * from t_student"];
    if(resultSet){
        [self.stuDataList removeAllObjects];
        while ([resultSet next]) {
            Student* stu = [Student new];
            stu.stu_id = [resultSet intForColumn:@"id"];
            stu.stu_name = [resultSet stringForColumn:@"name"];
            stu.stu_age = [resultSet intForColumn:@"age"];
            stu.stu_sex = [resultSet stringForColumn:@"sex"];
            [self.stuDataList addObject:stu];
        }
    }else{
        NSLog(@"query fail");
    }
    [_myDB close];
}


#pragma - mark  另外还有个重要的线程安全问题
//FMDB是用队列以及事务来完成

- (void)insertMutiData{
    __block BOOL isSuccess = YES;
    [_myDB open];
    FMDatabaseQueue* dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    [dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        // 串行队列
        isSuccess = [db executeUpdate:@"insert into t_student(name, age, sex) values (?, ?, ?)", @"隔壁老王", @38, @"男"] && isSuccess;
        isSuccess = [db executeUpdate:@"insert into t_student(name, age, sex) values (?, ?, ?)", @"-1", @438, @"男"] && isSuccess;
        isSuccess = [db executeUpdate:@"insert into t_student(name, age, sex) values (?, ?, ?)", @"Rose", @18, @"女"] && isSuccess;

        if(!isSuccess){
            *rollback = YES;
            return ;
        }
        
    }];
    [_myDB close];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 10;
    return self.stuDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StudentTBCell* cell = [tableView dequeueReusableCellWithIdentifier:@"StudentTBCell"];
    cell.student = self.stuDataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Student* cellStu = self.stuDataList[indexPath.row];
    self.idLbl.text = [NSString stringWithFormat:@"%d",cellStu.stu_id];
    self.nameTextField.text = cellStu.stu_name;
    self.ageTextField.text = [NSString stringWithFormat:@"%d",cellStu.stu_age];
    self.sexTextField.text = cellStu.stu_sex;
}

@end
