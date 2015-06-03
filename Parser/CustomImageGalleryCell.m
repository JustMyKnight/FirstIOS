//
//  CustomImageGalleryCell.m
//  Parser
//
//  Created by Admin on 03.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CustomImageGalleryCell.h"

@implementation CustomImageGalleryCell

- (void)awakeFromNib {
    // Initialization code
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
