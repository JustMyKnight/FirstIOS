//
//  MasterViewController.h
//  Parser
//
//  Created by Admin on 05.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

-(void) openlastnews;

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

