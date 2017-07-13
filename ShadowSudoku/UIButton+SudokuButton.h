//
//  UIButton+SudokuButton.h
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-12.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SudokuButton)

+(UIButton *)buttonWithSudokuStyleForTag:(NSInteger)tag sudokuEntry:(NSInteger)entry inGrid:(UIView *)gridCellView;

@end
