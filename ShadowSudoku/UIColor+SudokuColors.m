//
//  UIColor+SudokuColors.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-13.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "UIColor+SudokuColors.h"

@implementation UIColor (SudokuColors)

+(UIColor *)titleColorForEntry:(NSInteger)entry {
    return (entry == 0) ? [UIColor blackColor] : [UIColor whiteColor];
}

+(UIColor *)backgroundColorForEntry:(NSInteger)entry {
    return (entry == 0) ? [UIColor whiteColor] : [UIColor blackColor];
}

+(UIColor *)unHighlightedColor {
    return [UIColor clearColor];
}

+(UIColor *)highlightColorForBox {
    return [UIColor lightGrayColor];
}

+(UIColor *)highlightColorForRow {
    return [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
}

+(UIColor *)highlightColorForColumn {
    return [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
}

@end
