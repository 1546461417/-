//
//  GFCalendarScrollView.m
//
//  Created by Mercy on 2019/4/15.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import "GFCalendarScrollView.h"
#import "GFCalendarCell.h"
#import "GFCalendarMonth.h"
#import "NSDate+GFCalendar.h"
#define OCSTR(...)                      [NSString stringWithFormat:__VA_ARGS__]
@interface GFCalendarScrollView() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionViewL;
@property (nonatomic, strong) UICollectionView *collectionViewM;
@property (nonatomic, strong) UICollectionView *collectionViewR;
@property (nonatomic, strong) NSDate *currentMonthDate;
@property (nonatomic, strong) NSMutableArray *monthArray;
@end
@implementation GFCalendarScrollView
#define kCalendarBasicColor AppHTMLColor(@"4bccbc")
static NSString *const kCellIdentifier = @"cell";
#pragma mark - Initialiaztion

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([super initWithFrame:frame]) {
        
        //self.backgroundColor = [UIColor greenColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO];
        
        _currentMonthDate = [NSDate date];
        [self setupCollectionViews];
        
    }
    
    return self;
    
}

- (NSMutableArray *)monthArray {
    
    if (_monthArray == nil) {
        
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[GFCalendarMonth alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[GFCalendarMonth alloc] initWithDate:_currentMonthDate]];
        [_monthArray addObject:[[GFCalendarMonth alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部
        
        // 发通知，更改当前月份标题
        [self notifyToChangeCalendarHeader];
    }
    
    return _monthArray;
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}


- (void)setupCollectionViews {
        
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width / 7.0, self.bounds.size.width / 7.0);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    _collectionViewL = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewL.dataSource = self;
    _collectionViewL.delegate = self;
    _collectionViewL.backgroundColor = [UIColor clearColor];
    [_collectionViewL registerClass:[GFCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewL];
    
    _collectionViewM = [[UICollectionView alloc] initWithFrame:CGRectMake(selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewM.dataSource = self;
    _collectionViewM.delegate = self;
    _collectionViewM.backgroundColor = [UIColor clearColor];
    [_collectionViewM registerClass:[GFCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewM];
    
    _collectionViewR = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewR.dataSource = self;
    _collectionViewR.delegate = self;
    _collectionViewR.backgroundColor = [UIColor clearColor];
    [_collectionViewR registerClass:[GFCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewR];

}


#pragma mark -

- (void)notifyToChangeCalendarHeader {
    
    GFCalendarMonth *currentMonthInfo = self.monthArray[1];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.year] forKey:@"year"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.month] forKey:@"month"];
    
    NSNotification *notify = [[NSNotification alloc] initWithName:@"ChangeCalendarHeaderNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)refreshToCurrentMonth {
    
    // 如果现在就在当前月份，则不执行操作
    GFCalendarMonth *currentMonthInfo = self.monthArray[1];
    if ((currentMonthInfo.month == [[NSDate date] dateMonth]) && (currentMonthInfo.year == [[NSDate date] dateYear])) {
        return;
    }
    
    _currentMonthDate = [NSDate date];
    
    NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
    NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:[[GFCalendarMonth alloc] initWithDate:previousMonthDate]];
    [self.monthArray addObject:[[GFCalendarMonth alloc] initWithDate:_currentMonthDate]];
    [self.monthArray addObject:[[GFCalendarMonth alloc] initWithDate:nextMonthDate]];
    [self.monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]];
    
    // 刷新数据
    [_collectionViewM reloadData];
    [_collectionViewL reloadData];
    [_collectionViewR reloadData];
    
}


#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; // 7 * 6
}
//字符串转日期格式
- (NSDate *)stringToDate:(NSString *)dateString withDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return [self worldTimeToChinaTime:date];
}

//将时间转化为系统对应的时区时间
- (NSDate *)worldTimeToChinaTime:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
    return localeDate;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     long index = collectionView == _collectionViewL ? 0 : collectionView == _collectionViewM ? 1 : 2;
     long indexSe = collectionView == _collectionViewL ? 3 : collectionView == _collectionViewM ? 0 : 1;
    GFCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (collectionView) {
        GFCalendarMonth *monthInfo = self.monthArray[index];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor darkGrayColor];
            cell.cancleCnaLabel.textColor = [UIColor darkGrayColor];
            
         
            cell.cancleCnaLabel.text = [self getContent:OCSTR(@"%ld",monthInfo.year) month:OCSTR(@"%02ld",monthInfo.month) days:OCSTR(@"%02ld",indexPath.row - firstWeekday + 1)];
            
            NSString *cotent = @"春节元宵端午七夕中元中秋重阳腊八小年";
            if ([cotent containsString:cell.cancleCnaLabel.text == nil ? @"  ":cell.cancleCnaLabel.text]) {
                cell.cancleCnaLabel.textColor = [UIColor redColor];
            }
            
            NSString *gContent = [self getLunarSpecialDate:(int)monthInfo.year Month:(int)monthInfo.month Day:(int)(indexPath.row - firstWeekday + 1)];
            if (gContent ) {
                cell.cancleCnaLabel.text = gContent;
                cell.cancleCnaLabel.textColor = [UIColor redColor];
            }
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = kCalendarBasicColor;
                    cell.todayLabel.textColor = [UIColor whiteColor];
        
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            NSInteger totalDaysOflastMonth = 0 ;
            if (collectionView == _collectionViewL) {
                totalDaysOflastMonth = [self.monthArray[indexSe] integerValue];
            }else{
                GFCalendarMonth *lastMonthInfo = self.monthArray[indexSe];
                totalDaysOflastMonth = lastMonthInfo.totalDays;
            }
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            long realYerar = monthInfo.month == 1 ? monthInfo.year - 1 : monthInfo.year;
            long realMonth = monthInfo.month == 1 ?  12 : monthInfo.month - 1;
            cell.cancleCnaLabel.text = [self getContent:OCSTR(@"%ld",realYerar) month:OCSTR(@"%02ld",realMonth) days:OCSTR(@"%02ld",totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1)];
            cell.cancleCnaLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            cell.todayCircle.backgroundColor = [UIColor clearColor];
            long realYerar = monthInfo.month == 12 ? monthInfo.year + 1 : monthInfo.year;
            long realMonth = monthInfo.month == 12  ?  1 : monthInfo.month + 1;
            cell.cancleCnaLabel.text = [self getContent:OCSTR(@"%ld",realYerar) month:OCSTR(@"%02ld",realMonth) days:OCSTR(@"%02ld",indexPath.row - firstWeekday - totalDays + 1)];
          cell.cancleCnaLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            
        }
       
        
    }
    
    return cell;
    
}

- (NSString *)getContent:(NSString *)year month:(NSString *)month days:(NSString *)day{
    NSString *dataString = [ [year stringByAppendingString:month] stringByAppendingString:day];
    NSDate *newdate = [self stringToDate:dataString withDateFormat:@"yyyyMMdd"];
    return [self getChineseCalendarWithDate:newdate];
}

-(NSString*)getChineseCalendarWithDate:(NSDate *)date{
    
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
   // NSLog(@"%zd_%zd_%zd",localeComp.year,localeComp.month,localeComp.day);
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    NSString *chineseCal_str =[NSString stringWithFormat: @"%@_%@_%@",y_str,m_str,d_str];
    
    
    NSDictionary *dict = @{
                           @"正月初一":@"春节",
                           @"正月十五":@"元宵",
                           @"五月初五":@"端午",
                           @"七月初七":@"情人节",
                           @"七月十五":@"中元节",
                           @"八月十五":@"中秋节",
                           @"腊月初八":@"腊八",
                           @"腊月廿四":@"小年"
                           };
    
    
    
    NSString *key_str = [NSString stringWithFormat:@"%@%@",m_str,d_str];
    NSString *content = [dict objectForKey:key_str];
    if (content) {
        d_str = content;
    }
    return d_str;
}





const  int START_YEAR =1901;
const  int END_YEAR   =2050;

static int32_t gLunarHolDay[]=
{
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1901
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1902
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1903
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //1904
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1905
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1906
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1907
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1908
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1909
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1910
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1911
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1912
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1913
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1914
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1915
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1916
    0X95, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1917
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77,   //1918
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1919
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1920
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1921
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77,   //1922
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1923
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1924
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1925
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1926
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1927
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1928
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1929
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1930
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1931
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1932
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1933
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1934
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1935
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1936
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1937
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1938
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1939
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1940
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1941
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1942
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1943
    0X96, 0XA5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1944
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1945
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1946
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1947
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1948
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X79, 0X77, 0X87,   //1949
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1950
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1951
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1952
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1953
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X68, 0X78, 0X87,   //1954
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1955
    0X96, 0XA5, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1956
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1957
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1958
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1959
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1960
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1961
    0X96, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1962
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1963
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1964
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1965
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1966
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1967
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1968
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1969
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1970
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1971
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1972
    0XA5, 0XB5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1973
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1974
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1975
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X89, 0X88, 0X78, 0X87, 0X87,   //1976
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1977
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //1978
    0X96, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1979
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1980
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X77, 0X87,   //1981
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1982
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1983
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //1984
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1985
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1986
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X69, 0X78, 0X87,   //1987
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1988
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1989
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1990
    0X95, 0XB4, 0X96, 0XA5, 0X86, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1991
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1992
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1993
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1994
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X76, 0X78, 0X69, 0X78, 0X87,   //1995
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1996
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1997
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1998
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1999
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2000
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2001
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2002
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //2003
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2004
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2005
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2006
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //2007
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2008
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2009
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2010
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //2011
    0X96, 0XB4, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2012
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2013
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2014
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2015
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2016
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2017
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2018
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2019
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86,   //2020
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2021
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2022
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2023
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2024
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2025
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2026
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2027
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2028
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2029
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2030
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2031
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2032
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X86,   //2033
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X78, 0X88, 0X78, 0X87, 0X87,   //2034
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2035
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2036
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2037
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2038
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2039
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2040
    0XA5, 0XC3, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2041
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2042
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2043
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X88, 0X87, 0X96,   //2044
    0XA5, 0XC3, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2045
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2046
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2047
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA5, 0X97, 0X87, 0X87, 0X88, 0X86, 0X96,   //2048
    0XA4, 0XC3, 0XA5, 0XA5, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86,   //2049
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X78, 0X78, 0X87, 0X87    //2050
    
};

- (NSString *)getLunarSpecialDate:(int)iYear Month:(int)iMonth  Day:(int)iDay  {
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"小寒", @"大寒", @"立春", @"雨水", @"惊蛰", @"春分",
                          
                          @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至",
                          
                          @"小暑", @"大暑", @"立秋", @"处暑", @"白露", @"秋分",
                          
                          @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至", nil];
    
    
    int array_index = (iYear - START_YEAR) * 12 + iMonth -1 ;
    
    
    int64_t flag = gLunarHolDay[array_index];
    int64_t day;
    
    if(iDay <15)
        day= 15 - ((flag>>4)&0x0f);
    else
        day = ((flag)&0x0f)+15;
    
    int index = -1;
    
    if(iDay == day){
        index = (iMonth-1) *2 + (iDay>15? 1: 0);
    }
    
    if ( index >= 0  && index < [chineseDays count] ) {
        return [chineseDays objectAtIndex:index];
    } else {
        return nil;
    }
    
}














#pragma mark - UICollectionViewDeleagate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.didSelectDayHandler != nil) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:_currentMonthDate];
        NSDate *currentDate = [calendar dateFromComponents:components];
        
        GFCalendarCell *cell = (GFCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.todayCircle.backgroundColor = kCalendarBasicColor;
        cell.todayLabel.textColor = [UIColor whiteColor];

        NSInteger year = [currentDate dateYear];
        NSInteger month = [currentDate dateMonth];
        NSInteger day = [cell.todayLabel.text integerValue];
        
        self.didSelectDayHandler(year, month, day); // 执行回调
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        return;
    }
    
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *previousDate = [_currentMonthDate previousMonthDate];
        
        // 数组中最左边的月份现在作为中间的月份，中间的作为右边的月份，新的左边的需要重新获取
        GFCalendarMonth *currentMothInfo = self.monthArray[0];
        GFCalendarMonth *nextMonthInfo = self.monthArray[1];
        
        
        GFCalendarMonth *olderNextMonthInfo = self.monthArray[2];
        
        // 复用 GFCalendarMonth 对象
        olderNextMonthInfo.totalDays = [previousDate totalDaysInMonth];
        olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth];
        olderNextMonthInfo.year = [previousDate dateYear];
        olderNextMonthInfo.month = [previousDate dateMonth];
        GFCalendarMonth *previousMonthInfo = olderNextMonthInfo;
        
        NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[_currentMonthDate previousMonthDate]];
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate nextMonthDate];
        NSDate *nextDate = [_currentMonthDate nextMonthDate];
        
        // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
        GFCalendarMonth *previousMonthInfo = self.monthArray[1];
        GFCalendarMonth *currentMothInfo = self.monthArray[2];
        
        
        GFCalendarMonth *olderPreviousMonthInfo = self.monthArray[0];
        
        NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.totalDays]; // 先保存 olderPreviousMonthInfo 的月天数
        
        // 复用 GFCalendarMonth 对象
        olderPreviousMonthInfo.totalDays = [nextDate totalDaysInMonth];
        olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
        olderPreviousMonthInfo.year = [nextDate dateYear];
        olderPreviousMonthInfo.month = [nextDate dateMonth];
        GFCalendarMonth *nextMonthInfo = olderPreviousMonthInfo;

        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    
    [_collectionViewM reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [_collectionViewL reloadData]; // 最后两边的 collectionView 也刷新数据
    [_collectionViewR reloadData];
    
    // 发通知，更改当前月份标题
    [self notifyToChangeCalendarHeader];
    
}

@end
