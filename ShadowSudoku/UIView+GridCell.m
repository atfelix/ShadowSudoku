//
//  UIView+GridCell.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-13.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "UIView+GridCell.h"

@implementation UIView (GridCell)

+(UIView *)viewWithSudokuCellStyleInSuperView:(UIView *)superView atBoxRow:(NSInteger)row boxColumn:(NSInteger)column {
    return [UIView viewWithSudokuCellStyleInSuperView:superView
                                            withWidth:(superView.bounds.size.width - 20) / 3
                                             atBoxRow:row
                                            boxColumn:column];
}

+(UIView *)viewWithButtonGridCellStyleInSuperView:(UIView *)superView atBoxRow:(NSInteger)row boxColumn:(NSInteger)column {
    return [UIView viewWithSudokuCellStyleInSuperView:superView
                                            withWidth:(superView.bounds.size.width - 20) / 2.5
                                             atBoxRow:row
                                            boxColumn:column];
}

+(UIView *)viewWithSudokuCellStyleInSuperView:(UIView *)superView withWidth:(CGFloat)width atBoxRow:(NSInteger)row boxColumn:(NSInteger)column {
    UIView *gridCellView = [[UIView alloc] initWithFrame:CGRectMake(column * width, row * width, width, width)];
    gridCellView.userInteractionEnabled = YES;
    [gridCellView setupViewWithUserInteraction: YES
                               withBorderColor:[UIColor grayColor]
                                   borderWidth:2.5
                               backgroundColor:[UIColor clearColor]];
    return gridCellView;
}

-(void)setupViewWithUserInteraction:(BOOL)userInteraction withBorderColor:(UIColor *)color borderWidth:(CGFloat)width backgroundColor:(UIColor *)bgColor {
    self.userInteractionEnabled = userInteraction;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.backgroundColor = bgColor;
}

@end
