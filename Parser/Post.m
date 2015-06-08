//
//  Post.m
//  Parser
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "Post.h"

@implementation Post

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.linkToFullPost = [aDecoder decodeObjectForKey:@"linkToFullPost"];
        self.linkToPreview = [aDecoder decodeObjectForKey:@"linkToPreview "];
        self.timePosted = [aDecoder decodeObjectForKey:@"timePosted"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_linkToFullPost forKey:@"linkToFullPost"];
    [aCoder encodeObject:_linkToPreview forKey:@"linkToPreview "];
    [aCoder encodeObject:_timePosted forKey:@"timePosted"];
}

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
