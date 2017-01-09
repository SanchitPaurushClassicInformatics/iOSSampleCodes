//
//  MiddayPicksViewController.m
//  Luck Pocket
//
//  Created by Neha on 26/08/16.
//  Copyright © 2016 Neha. All rights reserved.
//

#import "MiddayPicksViewController.h"
#import "ThreedigitTableViewCell.h"
#import "FourdigitTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@interface MiddayPicksViewController ()
@property (weak, nonatomic) IBOutlet UITableView *middaytableview; //midday table view outlet
@property (weak, nonatomic) IBOutlet UILabel *eveningNumber; // evening numbers

@end
NSMutableArray * numberarr; //array for whole digits
NSMutableArray * win4arr; //array for win4 digits
NSString * finalDate; // final date display after convert into format
UIView * additionalSeparator; // custom seperator for table view
@implementation MiddayPicksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dateformat];
    self.middaytableview.tableFooterView = [[UIView alloc] init];
    //change format of date with suffix ==================================
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setDateFormat:@"MMMM d, yyyy"];
    [prefixDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    prefixDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    prefixDateFormatter.locale = [NSLocale currentLocale];
    NSDate *date = [prefixDateFormatter dateFromString:_eventDate];
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    monthDayFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    monthDayFormatter.locale = [NSLocale currentLocale];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:date] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    NSString *dateString = _eventDate;
    NSLog(@"%@", dateString);
    finalDate = dateString;
    NSRange lastComma = [finalDate rangeOfString:@"," options:NSBackwardsSearch];
    NSString *replacedstr = [NSString stringWithFormat:@"%@,",suffix];
    if(lastComma.location != NSNotFound) {
        finalDate = [finalDate stringByReplacingCharactersInRange:lastComma
                                                             withString: replacedstr];
    }
    NSLog(@"updated string is %@",finalDate);
   _eventdate.text = finalDate;
    numberarr = [[NSMutableArray alloc] init];
    win4arr = [[NSMutableArray alloc] init];
    NSLog(@"midday array ===%@",_middaySlotlist);
    numberarr = [_middaySlotlist valueForKey:@"number"];
    win4arr = [_middaySlotlist valueForKey:@"win4"];
    _middaytableview.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated {
    _middaytableview.hidden = NO;
    [_middaytableview reloadData];
}
-(void)dateformat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //// here set format of date which is in your output date (means above str with format)
    NSDate *date =[NSDate date]; // here you can fetch date from string with define format
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];// here set format which you want...
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale currentLocale];
    NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
    NSLog(@"Converted String : %@",convertedString);
    _eventdate.text = convertedString ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setRoundedView:(UILabel *)roundedView toDiameter:(float)newSize {
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.layer.borderWidth = 2.0;
    roundedView.layer.borderColor = [UIColor blackColor].CGColor;
}

#pragma mark table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}
- (void)scrollViewDidScroll: (UIScrollView *)scroll {
    // UITableView only moves in one direction, y axis
    CGFloat currentOffset = scroll.contentOffset.y;
    CGFloat maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        self.shadowImage.hidden = YES;
    }
    else{
        self.shadowImage.hidden = NO;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![_isWin4 isEqualToString:@"true"]) {
        static NSString *numberTableIdentifier = @"3digitcell";
        ThreedigitTableViewCell *cell = [_middaytableview dequeueReusableCellWithIdentifier:numberTableIdentifier];
        if (cell == nil) {
            cell = [[ThreedigitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:numberTableIdentifier];
        }
        self.shadowImage.hidden = NO;
        NSArray *arrSubView = cell.subviews;
        for(UIButton *subView in arrSubView) {
            if([subView isKindOfClass:[UIButton class]]) {
                [subView removeFromSuperview];
            }
        }
        NSString *originalString;
        NSString * firstString;
        NSString * secondString;
        NSString * thirdString;
        originalString = [numberarr objectAtIndex:indexPath.row];
        NSLog(@"original string ===========s%@",originalString);
        firstString = [NSString stringWithFormat:@"%c", [[numberarr objectAtIndex:indexPath.row] characterAtIndex:0]];
        secondString = [NSString stringWithFormat:@"%c",[[numberarr objectAtIndex:indexPath.row] characterAtIndex:1]];
        thirdString = [NSString stringWithFormat:@"%c", [[numberarr objectAtIndex:indexPath.row] characterAtIndex:2]];
        NSLog(@"%@%@%@",firstString,secondString,thirdString);
        
        cell.firstNumber.text = firstString;
        cell.secondNumber.text = secondString;
        cell.thirdNumber.text = thirdString;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        cell.sumnumber.text = [NSString stringWithFormat:@"%d",[firstString intValue]+ [secondString intValue]+[thirdString intValue]];
       
        _eveningNumber.text = @"Midday Pick 3";

        return cell;
    }
    else {
        static NSString *win4dentifier = @"4digitcell";
        FourdigitTableViewCell *cell1 = [_middaytableview dequeueReusableCellWithIdentifier:win4dentifier];
        
        if (cell1 == nil) {
            
            cell1 = [[FourdigitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:win4dentifier];
            
        }
        NSArray *arrSubView = cell1.contentView.subviews;
        for(UIButton *subView in arrSubView){
            // if(subView.tag == 101 || subView.tag == 102 || subView.tag == 103){
            if([subView isKindOfClass:[UIButton class]]) {
                [subView removeFromSuperview];
            }
        }

        [cell1 setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSString *originalString = [win4arr objectAtIndex:indexPath.row];
        NSString * firstString = [NSString stringWithFormat:@"%c", [originalString characterAtIndex:0]];
        NSString * secondString = [NSString stringWithFormat:@"%c", [originalString characterAtIndex:1]];
        NSString * thirdString = [NSString stringWithFormat:@"%c", [originalString characterAtIndex:2]];
        NSString * fourthString = [NSString stringWithFormat:@"%c", [originalString characterAtIndex:3]];
        cell1.firstNumber.text = firstString;
        cell1.secondNumber.text = secondString;
        cell1.thirdNumber.text = thirdString;
        cell1.fourthNumber.text = fourthString;
        NSLog(@"%@%@%@%@",firstString,secondString,thirdString,fourthString);
        cell1.totalSum.text = [NSString stringWithFormat:@"%d",[firstString intValue]+ [secondString intValue]+ [thirdString intValue]+[fourthString intValue] ];
      _eveningNumber.text = @"Midday Pick 4";
        return cell1;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if([_isWin4 isEqualToString:@"true"])
    {
        return win4arr.count ;
    }
    else {
        return   numberarr.count;
    }
}

@end
