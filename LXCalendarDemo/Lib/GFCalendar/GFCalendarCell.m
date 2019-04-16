//
//  GFCalendarCell.m
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import "GFCalendarCell.h"

@implementation GFCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.todayCircle];
        [self addSubview:self.todayLabel];
        [self addSubview:self.cancleCnaLabel];
        
        
    }
    
    return self;
}

- (UIView *)todayCircle {
    if (_todayCircle == nil) {
        _todayCircle = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,  self.bounds.size.height,  self.bounds.size.height)];
       
        _todayCircle.layer.cornerRadius = self.frame.size.width/2;
        _todayCircle.layer.masksToBounds = YES;
    }
    return _todayCircle;
}

- (UILabel *)todayLabel {
    if (_todayLabel == nil) {
        _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _todayLabel.backgroundColor = [UIColor clearColor];
    }
    return _todayLabel;
}


- (UILabel *)cancleCnaLabel {
    if (_cancleCnaLabel == nil) {
        _cancleCnaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_todayLabel.frame) , self.frame.size.width ,self.frame.size.height/2)];
        _cancleCnaLabel.textAlignment = NSTextAlignmentCenter;
        _cancleCnaLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _cancleCnaLabel.backgroundColor = [UIColor clearColor];
    }
    return _cancleCnaLabel;
}


@end
