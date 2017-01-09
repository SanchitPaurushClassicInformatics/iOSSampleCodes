//
//  MiddayPicksViewController.h
//  Luck Pocket
//
//  Created by Neha on 26/08/16.
//  Copyright © 2016 Neha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiddayPicksViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *eventdate;
@property (strong) NSMutableDictionary * middaySlotlist;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;
@property (strong) NSString * isWin4;
@property (strong) NSString * eventDate;
@end
