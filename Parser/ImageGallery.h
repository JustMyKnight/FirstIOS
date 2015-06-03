//
//  ImageGallery.h
//  Parser
//
//  Created by Admin on 03.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGallery : UIViewController

@property (strong, nonatomic) NSMutableArray *imageViewArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property int currentCell;

@end
