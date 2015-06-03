//  TodayViewController.m
//  Widget
//
//  Created by Admin on 14.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TFHpple.h"
#import "Post.h"

@interface TodayViewController () <NCWidgetProviding, NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *htmlData;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

@implementation TodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    self.preferredContentSize = CGSizeMake(300, 88);
    [self pagedownload];
}

//Go to news on single tap
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSURL *pjURL = [NSURL URLWithString:@"AppUrlType://home/"];
    [self.extensionContext openURL:pjURL completionHandler:nil];
}

- (void) pagedownload
{
    NSString *url_str = @"http://live.goodline.info/guest";
    NSURL *url = [NSURL URLWithString: url_str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

//Parse last news from live.goodline.info
- (void) widgetparser: (NSMutableData *)data
{
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    TFHppleElement *postNode = postNodes[0];
    Post *post = [[Post alloc] init];
    TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
    TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
    post.title = titleNode.text;
    self.titleLabel.text = titleNode.text;
    TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
    if (imageNode)
    {
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [imageNode objectForKey:@"src"]]]];
        post.linkToPreview = [imageNode objectForKey:@"src"];
        self.previewImageView.image = image;
    }
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    completionHandler(NCUpdateResultNewData);
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.htmlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.htmlData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self widgetparser:self.htmlData];
}

@end
