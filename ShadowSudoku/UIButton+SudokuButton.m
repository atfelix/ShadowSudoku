//
//  UIButton+SudokuButton.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "UIButton+SudokuButton.h"

#import "Sudoku.h"
#import "UIColor+SudokuColors.h"

@implementation UIButton (SudokuButton)

+(UIButton *)buttonWithSudokuStyleForTag:(NSInteger)tag sudokuEntry:(NSInteger)entry inGrid:(UIView *)gridCellView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setButtonFrameForTag:tag inGrid:gridCellView];
    [button setColorsForEntry:entry];
    [button setBorderWidth:1.0];
    [button setTitleForEntry:entry];
    [button setButtonTag:tag];

    return button;
}

-(void)setColorsForEntry:(NSInteger)entry {
    UIColor *titleColor = [UIColor titleColorForEntry:entry];

    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.layer.borderColor = titleColor.CGColor;
    self.backgroundColor = [UIColor backgroundColorForEntry:entry];
}

-(void)setBorderWidth:(CGFloat)width {
    self.layer.borderWidth = width;
}

-(void)setTitleForEntry:(NSInteger)entry {
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitle:[NSString stringWithFormat:@"%@", (entry != 0) ? @(entry) : @""]
            forState:UIControlStateNormal];
}

-(void)setButtonTag:(NSInteger)tag {
    NSInteger boxRow = [Sudoku boxRowForTag:tag], boxColumn = [Sudoku boxColumnForTag:tag];
    NSInteger boxSubRow = [Sudoku boxSubRowForTag:tag], boxSubColumn = [Sudoku boxSubColumnForTag:tag];
    self.tag = (boxRow * 3 + boxSubRow) * 9 + boxColumn * 3 + boxSubColumn;
}

-(void)setButtonFrameForTag:(NSInteger)tag inGrid:(UIView *)gridCellView {
    CGFloat width = gridCellView.frame.size.width / 3;
    NSInteger boxSubRow = [Sudoku boxSubRowForTag:tag], boxSubColumn = [Sudoku boxSubColumnForTag:tag];

    self.frame = CGRectMake(boxSubColumn * width,
                            boxSubRow * width,
                            width,
                            width);
}

@end
