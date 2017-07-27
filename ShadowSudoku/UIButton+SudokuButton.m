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

+(UIButton *)buttonWithSudokuStyleForTag:(NSInteger)tag sudoku:(Sudoku *)sudoku inGrid:(UIView *)gridCellView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSInteger entry = [[sudoku numberAtTag:tag] integerValue];

    [button setButtonFrameForTag:tag inGrid:gridCellView forSudoku:sudoku];
    [button setColorsForEntry:entry];
    [button setBorderWidth:1.0];
    [button setTitleForEntry:entry];
    [button setButtonTag:tag inSudoku:sudoku];
    [button setLabelsForTag:tag inSudoku:sudoku];

    return button;
}

+(UIButton *)inputButtonForDigit:(NSInteger)digit inGrid:(UIView *)gridCellView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setButtonFrameForDigit:digit - 1 inGrid:gridCellView];
    [button setColorsForEntry:0];
    [button setBorderWidth:1.0];
    [button setTitleForEntry:digit];
    button.tag = digit;

    return button;
}

+(UIButton *)arrowButtonForInteger:(NSInteger)integer inGrid:(UIView *)gridCellView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setButtonFrameForDigit:integer inGrid:gridCellView];
    [button setColorsForEntry:0];
    [button setBorderWidth:1.0];
    [button setTitleForArrowInteger:integer];
    button.tag = integer;

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

-(void)setTitleForArrowInteger:(NSInteger)integer {
    NSArray *arrows = @[@"↖", @"↑", @"↗", @"←", @"✖", @"→", @"↙", @"↓", @"↘"];

    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitle:arrows[integer]
          forState:UIControlStateNormal];
}

-(void)setButtonTag:(NSInteger)tag inSudoku:(Sudoku *)sudoku {
    NSInteger boxRow = [sudoku boxRowForTag:tag], boxColumn = [sudoku boxColumnForTag:tag];
    NSInteger boxSubRow = [sudoku boxSubRowForTag:tag], boxSubColumn = [sudoku boxSubColumnForTag:tag];
    self.tag = (boxRow * 3 + boxSubRow) * 9 + boxColumn * 3 + boxSubColumn;
}

-(void)setButtonFrameForTag:(NSInteger)tag inGrid:(UIView *)gridCellView forSudoku:(Sudoku *)sudoku {
    CGFloat width = gridCellView.frame.size.width / 3;
    NSInteger boxSubRow = [sudoku boxSubRowForTag:tag], boxSubColumn = [sudoku boxSubColumnForTag:tag];

    self.frame = CGRectMake(boxSubColumn * width,
                            boxSubRow * width,
                            width,
                            width);
}

-(void)setButtonFrameForDigit:(NSInteger)digit inGrid:(UIView *)gridCellView {
    CGFloat width = gridCellView.frame.size.width / 3;
    NSInteger row = digit / 3, column = digit % 3;

    self.frame = CGRectMake(column * width,
                            row * width,
                            width,
                            width);
}

-(void)setLabelsForTag:(NSInteger)tag inSudoku:(Sudoku *)sudoku {
    NSInteger entry = [[sudoku numberAtTag:tag] integerValue];
    NSSet *possibleEntries = [sudoku allowableEntriesForTag:tag];

    if (entry != 0) {
        return;
    }

    CGFloat width = self.bounds.size.width / 3;

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(j * width, i * width, width, width)];
            NSInteger entry = 3 * i + j + 1;
            label.text = [NSString stringWithFormat:@"%@", ([possibleEntries containsObject:@(entry)]) ? @(entry) : @""];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = entry;
            [self addSubview:label];
        }
    }
}

-(void)resetSubviewsWithAlpha:(CGFloat)alpha {
    for (UIView *view in self.subviews) {
        if (view.tag > 0) {
            view.alpha = alpha;
        }
    }
}

-(void)updateDigitButtonInSudoku:(Sudoku *)sudoku forTag:(NSInteger)tag {
    NSSet *allowableEntries = [sudoku allowableEntriesForTag:tag];
    self.enabled = [allowableEntries containsObject:@(self.tag)];
    self.backgroundColor = (self.isEnabled) ? [UIColor backgroundColorForEntry:0] : [UIColor backgroundColorForEntry:1];
    [self setTitleColor:(self.isEnabled) ? [UIColor backgroundColorForEntry:1] : [UIColor backgroundColorForEntry:0]
                 forState:UIControlStateNormal];
    self.layer.borderColor = self.currentTitleColor.CGColor;
}

@end
