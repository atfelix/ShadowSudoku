//
//  UIColor+SudokuColors.h
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-13.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SudokuColors)

+(UIColor *)titleColorForEntry:(NSInteger)entry;
+(UIColor *)backgroundColorForEntry:(NSInteger)entry;

@end
