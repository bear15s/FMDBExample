//
//  Student.h
//  FMDBExample
//
//  Created by zbmy on 2018/6/19.
//  Copyright © 2018年 HakoWaii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject
@property(nonatomic,assign)int stu_id;
@property(nonatomic,strong)NSString* stu_name;
@property(nonatomic,strong)NSString* stu_sex;
@property(nonatomic,assign)int stu_age;
@end
