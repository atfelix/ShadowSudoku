//
//  UIView+GridCell.h
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-13.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GridCell)

+(UIView *)viewWithSudokuCellStyleInSuperView:(UIView *)superView atBoxRow:(NSInteger)row boxColumn:(NSInteger)column;

@end
