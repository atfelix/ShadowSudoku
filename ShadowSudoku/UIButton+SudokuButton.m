//
//  UIButton+SudokuButton.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "UIButton+SudokuButton.h"

#import "Sudoku.h"

@implementation UIButton (SudokuButton)

+(UIButton *)buttonWithSudokuStyleForTag:(NSInteger)tag sudokuEntry:(NSInteger)entry inGrid:(UIView *)gridCellView {
    CGFloat width = gridCellView.frame.size.width / 3;
    NSInteger boxRow = [Sudoku boxRowForTag:tag], boxColumn = [Sudoku boxColumnForTag:tag];
    NSInteger boxSubRow = [Sudoku boxSubRowForTag:tag], boxSubColumn = [Sudoku boxSubColumnForTag:tag];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(boxSubColumn * width,
                              boxSubRow * width,
                              width,
                              width);
    UIColor *titleColor = (entry == 0) ? [UIColor blackColor] : [UIColor whiteColor];
    UIColor *bgColor = (entry == 0) ? [UIColor whiteColor] : [UIColor blackColor];

    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.layer.borderColor = titleColor.CGColor;
    button.layer.borderWidth = 1.0;
    button.backgroundColor = bgColor;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tag = (boxRow * 3 + boxSubRow) * 9 + boxColumn * 3 + boxSubColumn;
    [button setTitle:[NSString stringWithFormat:@"%@", (entry != 0) ? @(entry) : @""]
            forState:UIControlStateNormal];

    return button;
}

@end
