//
//  DetailViewController.m
//  Parser
//
//  Created by Admin on 05.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "DetailViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "TFHpple.h"
#import "ImageGallery.h"
@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSMutableArray *imageViewArray;
@property (strong, nonatomic) ImageGallery *imageGallery;
@property int yOffset;
@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
        leftBarButtonItem.tintColor = [UIColor blackColor];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView.scrollEnabled = TRUE;
    self.imageViewArray = [[NSMutableArray alloc] init];
}

- (void)imageViewTapGesture: (UITapGestureRecognizer *) gestureRecognizer
{
    self.imageGallery = nil;
    self.imageGallery = [[ImageGallery alloc] init];
    self.imageGallery.imageViewArray = self.imageViewArray;
    self.imageGallery.currentCell = (int)gestureRecognizer.view.tag;
    [self.navigationController pushViewController:self.imageGallery animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _yOffset = 0;
    NSMutableAttributedString *atrString = [[NSMutableAttributedString alloc] initWithString:_postTitle
                                            ];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    [self.imageViewArray removeAllObjects];
    UITextView *textBlock = [self createTextViewWithText:atrString];
    [_scrollView addSubview:textBlock];
    AFHTTPRequestOperationManager *data = [AFHTTPRequestOperationManager manager];
    data.responseSerializer = [AFHTTPResponseSerializer serializer];
    [data GET:_linkToFullPost parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
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

- (UIViewAutoresizing) setAutoresizing
{
    return (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
}

- (void)parser: (NSData *)data
{
    int tag = 0;
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSString *XpathString = @"//div[@class='topic-content text']";
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    TFHppleElement *postNode = postNodes[0];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@""];
    for (TFHppleElement *i in postNode.children)
    {
        if ([i.tagName isEqual:@"img"])
        {
            if (![content isEqual:@""])
            {
                UITextView *textBlock = [self createTextViewWithText:content];
                [_scrollView addSubview:textBlock];
                _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _yOffset);
                content = [[NSMutableAttributedString alloc] initWithString:@""];
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _yOffset, _scrollView.frame.size.width-10, _scrollView.frame.size.width*9/16)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:[i objectForKey:@"src"]]];
            imageView.userInteractionEnabled = YES;
            imageView.tag = tag;
            tag++;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGesture:)];
            [imageView addGestureRecognizer:tapGesture];
            imageView.autoresizingMask = [self setAutoresizing];
            
            [self.imageViewArray addObject:imageView];
            
            
            [_scrollView addSubview:imageView];
            _yOffset += imageView.frame.size.height;
        }
        else
        {
            NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:@""];
            tempString = [self FindContent:i];
            [content appendAttributedString:tempString];
        }
    }
   if (![content isEqual:@""])
    {
        UITextView *textBlock = [self createTextViewWithText:content];
        [_scrollView addSubview:textBlock];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _yOffset);
    }
    
}

- (NSAttributedString *)FindContent:(TFHppleElement *)node
{
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:@""];
    if ([node isTextNode])
    {
        if ([node.parent.tagName characterAtIndex:0] == 'h')
        {
            return [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n", node.content]
                    ];
        }
        NSString *text = [node.content stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"	" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"\n\n" withString:@""];
        return [[NSAttributedString alloc] initWithString: text];
    }
    else
    {
        if ([node hasChildren])
        {
            for (TFHppleElement *subNode in node.children)
            {
                if (![subNode.tagName isEqual:@"img"])
                    [resultString appendAttributedString:[self FindContent: subNode]];
            }
        }
    }
    return resultString;
}

- (UITextView *)createTextViewWithText: (NSMutableAttributedString *) string
{
    UITextView *textBlock = [[UITextView alloc] initWithFrame:CGRectMake(0, _yOffset, _scrollView.frame.size.width, 10)];
    textBlock.attributedText = string;
    textBlock.userInteractionEnabled = FALSE;
    textBlock.editable = FALSE;
    textBlock.scrollEnabled = FALSE;
    textBlock.textAlignment = NSTextAlignmentJustified;
    CGSize size = [textBlock systemLayoutSizeFittingSize:textBlock.contentSize];
    CGRect textRect = CGRectMake(10, _yOffset, _scrollView.frame.size.width-20, size.height);
    textBlock.frame = textRect;
    _yOffset += size.height;
    return textBlock;
}

- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end