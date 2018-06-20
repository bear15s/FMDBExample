//
//  StudentTBCell.m
//  FMDBExample
//
//  Created by zbmy on 2018/6/20.
//  Copyright © 2018年 HakoWaii. All rights reserved.
//

#import "StudentTBCell.h"
#import <Masonry.h>

@interface StudentTBCell()
@property(strong,nonatomic) UILabel* idLbl;
@property(strong,nonatomic) UITextField* nameTextField;
@property(strong,nonatomic) UITextField* ageTextField;
@property(strong,nonatomic) UITextField* sexTextField;
@end

@implementation StudentTBCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupUI];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if([super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel* idLbl = [[UILabel alloc]init];
    idLbl.textAlignment = NSTextAlignmentCenter;
    idLbl.text = @" id:";
    self.idLbl = idLbl;
    UITextField* nameTextField = [[UITextField alloc]init];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField = nameTextField;
    
    UITextField* ageTextField = [[UITextField alloc]init];
    ageTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.ageTextField = ageTextField;
    
    UITextField* sexTextField = [[UITextField alloc]init];
    sexTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.sexTextField = sexTextField;
    
    NSArray* masArr = @[idLbl,nameTextField,ageTextField,sexTextField];
    [masArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.contentView addSubview:obj];
    }];
    
    [masArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    
    [masArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
//        make.width.mas_equalTo(@(self.bounds.size.width / 4));
    }];
}

- (void)setStudent:(Student *)student{
    _student = student;
    self.idLbl.text = [NSString stringWithFormat:@"%d",_student.stu_id];
    self.nameTextField.text = _student.stu_name;
    self.ageTextField.text = [NSString stringWithFormat:@"%d",_student.stu_age];
    self.sexTextField.text = _student.stu_sex;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
