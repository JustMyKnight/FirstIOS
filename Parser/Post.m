//
//  Post.m
//  Parser
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "Post.h"

@implementation Post

-(instancetype)init
{
    self = [super init];
    
    _title = nil;
    _linkToPreview = nil;
    _linkToFullPost = nil;
    _timePosted = nil;
    
    return self;
}

@end
