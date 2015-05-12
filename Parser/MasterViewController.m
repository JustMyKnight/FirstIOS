//
//  MasterViewController.m
//  Parser
//
//  Created by Admin on 05.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "Post.h"
#import "CustomCell.h"
#import "UIImageView+AFNetworking.h"
@interface MasterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) DetailViewController *DetailViewController;
@property (strong, nonatomic) UINavigationController *DetailNavigationController;
@property int pageNumber;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"GoodLineNews";
    AFHTTPRequestOperationManager *data = [AFHTTPRequestOperationManager manager];
    data.responseSerializer = [AFHTTPResponseSerializer serializer];
    [data GET:@"http://live.goodline.info/guest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self parser:responseObject];
         
     }
      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network problem"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _posts = [[NSMutableArray alloc] init];
        _DetailViewController = [[DetailViewController alloc] init];
        _DetailNavigationController = [[UINavigationController alloc] initWithRootViewController:_DetailViewController];
        _pageNumber = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) parser:(NSData *)responseData
{
    TFHpple *parser = [TFHpple hppleWithHTMLData:responseData];
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    if (![postNodes count] == 0)
        _pageNumber += 1;
    for (TFHppleElement *postNode in postNodes)
    {
        Post *post = [[Post alloc] init];
        TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
        TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
        post.title = titleNode.text;
        post.linkToFullPost = [titleNode objectForKey:@"href"];
        post.timePosted = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        post.linkToPreview = [imageNode objectForKey:@"src"];
        [_posts addObject:post];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.mainLabel.text = [_posts[indexPath.row] title];
    [cell.imageBlock setImageWithURL: [NSURL URLWithString:[_posts[indexPath.row] linkToPreview]]];
    cell.subLabel.text = [[_posts[indexPath.row] timePosted] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _DetailViewController.linkToFullPost = [_posts[indexPath.row] linkToFullPost];
    _DetailViewController.postTitle = [_posts[indexPath.row] title];
    [self presentViewController:_DetailNavigationController animated:YES completion:nil];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];
    if(indexPath.row == totalRow -1)
    {
        AFHTTPRequestOperationManager *data = [AFHTTPRequestOperationManager manager];
        data.responseSerializer = [AFHTTPResponseSerializer serializer];
        [data GET:[NSString stringWithFormat:@"http://live.goodline.info/guest/page%ld", (long)(_pageNumber+1)] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self parser:responseObject];
         }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network problem"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             [alertView show];
         }];
    }
}

@end