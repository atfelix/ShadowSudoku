//
//  SudokuViewController.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-11.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "SudokuViewController.h"

#import "Sudoku.h"
#import "UIButton+SudokuButton.h"
#import "UIColor+SudokuColors.h"
#import "UIView+GridCell.h"

@interface SudokuViewController ()

@property (nonatomic, strong) Sudoku *sudoku;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSInteger focusTag;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SudokuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSudoku];
    [self setupSudokuGrid];
    [self setupDigitButtons];
    [self setupArrowButtons];
    [self setInitialFocus];
}

-(void)setupSudoku {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"n00b"
                                                     ofType:@"sudoku"];
    self.sudoku = [[Sudoku alloc] initFromContentsOfURL:[NSURL fileURLWithPath:path]];
}

-(void)setupSudokuGrid {
    [self setupGridView];

    self.buttons = [@[] mutableCopy];

    for (NSInteger i = 0; i < Sudoku.baseSize; i++) {
        for (NSInteger j = 0; j < Sudoku.baseSize; j++) {
            UIView *gridCellView = [UIView viewWithSudokuCellStyleInSuperView:self.view
                                                                     atBoxRow:i
                                                                    boxColumn:j];
            [self.gridView addSubview:gridCellView];
            [self setupBoxAtRow:i andColumn:j inGridView:gridCellView];
        }
    }

    [self.buttons sortUsingComparator:^NSComparisonResult(UIButton* a, UIButton* b) {
        return (NSComparisonResult) (a.tag > b.tag);
    }];
}

-(void)setupGridView {
    UIView *gridView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:gridView];
    [self setupGridViewConstraints:gridView];
    self.gridView = gridView;
}

-(void)setupGridViewConstraints:(UIView *)gridView {
    gridView.translatesAutoresizingMaskIntoConstraints = NO;
    gridView.userInteractionEnabled = YES;
    [gridView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [gridView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10.0].active = YES;
    [gridView.widthAnchor constraintEqualToConstant:self.view.bounds.size.width - 10].active = YES;
    [gridView.heightAnchor constraintEqualToAnchor:gridView.widthAnchor].active = YES;
}

-(void)setupBoxAtRow:(NSInteger)row andColumn:(NSInteger)column inGridView:(UIView *)gridCellView {

    for (NSInteger i = 0; i < Sudoku.baseSize; i++) {
        for (NSInteger j = 0; j < Sudoku.baseSize; j++) {
            NSInteger tag = (row * Sudoku.baseSize + i) * Sudoku.size + column * Sudoku.baseSize + j;
            UIButton *button = [UIButton buttonWithSudokuStyleForTag:tag
                                                         sudoku:self.sudoku
                                                              inGrid:gridCellView];
            [button addTarget:self
                       action:@selector(sudokuButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
            [self.buttons addObject:button];
            [gridCellView addSubview:button];
        }
    }
}

-(void)setupDigitButtons {
    UIView *gridCellView = [UIView viewWithButtonGridCellStyleInSuperView:self.view
                                                             atBoxRow:0
                                                            boxColumn:0];
    gridCellView.frame = CGRectMake(10,
                                    self.view.bounds.size.height - 10 - gridCellView.frame.size.height,
                                    gridCellView.frame.size.height,
                                    gridCellView.frame.size.width);
    [self.view addSubview:gridCellView];

    for (NSInteger digit = 1; digit < Sudoku.size + 1; digit++) {
        UIButton *button = [UIButton inputButtonForDigit:digit inGrid:gridCellView];
        [button addTarget:self
                   action:@selector(digitButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [gridCellView addSubview:button];
    }
}

-(void)setupArrowButtons {
    UIView *gridCellView = [UIView viewWithButtonGridCellStyleInSuperView:self.view
                                                                 atBoxRow:0
                                                                boxColumn:0];
    gridCellView.frame = CGRectMake(self.view.bounds.size.width - 10 - gridCellView.frame.size.width,
                                    self.view.bounds.size.height - 10 - gridCellView.frame.size.height,
                                    gridCellView.frame.size.height,
                                    gridCellView.frame.size.width);
    [self.view addSubview:gridCellView];

    for (NSInteger arrowInt = 0; arrowInt < Sudoku.size; arrowInt++) {
        UIButton *button = [UIButton arrowButtonForInteger:arrowInt inGrid:gridCellView];
        [button addTarget:self
                   action:@selector(arrowButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [gridCellView addSubview:button];
    }
}

-(void)setInitialFocus {
    self.focusTag = -1;

    for (NSInteger tag = 0; tag < Sudoku.size * Sudoku.size; tag++) {
        if ([[self.sudoku numberAtTag:tag] integerValue] == 0) {
            self.focusTag = tag;
            break;
        }
    }

    [self drawFocusElements];
}

-(void)drawFocusElements {
    [self drawFocusRow];
    [self drawFocusColumn];
    [self drawFocusBox];
    [self drawFocusBackground];
}

-(void)drawFocusBox {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku boxForTag:button.tag] == [Sudoku boxForTag:self.focusTag]) {
            button.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

-(void)drawFocusRow {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku rowForTag:button.tag] == [Sudoku rowForTag:self.focusTag]) {
            button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        }
    }
}

-(void)drawFocusColumn {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku columnForTag:button.tag] == [Sudoku columnForTag:self.focusTag]) {
            button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        }
    }
}

-(void)drawFocusBackground {
    if ([[self.sudoku originalNumberAtTag:self.focusTag] integerValue] == 0) {
        ((UIButton *)self.buttons[self.focusTag]).backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    }
}

-(void)sudokuButtonTapped:(UIButton *)sender {
    if ([[self.sudoku originalNumberAtTag:sender.tag] integerValue] != 0) {
        return;
    }

    [self clearFocusHighlights];
    self.focusTag = sender.tag;
    [self drawFocusElements];
}

-(void)clearFocusHighlights {
    [self clearFocusBox];
    [self clearFocusRow];
    [self clearFocusColumn];
}

-(void)clearFocusBox {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku boxForTag:button.tag] == [Sudoku boxForTag:self.focusTag]) {
            button.backgroundColor = [UIColor backgroundColorForEntry:0];
        }
    }
}

-(void)clearFocusRow {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku rowForTag:button.tag] == [Sudoku rowForTag:self.focusTag]) {
            button.backgroundColor = [UIColor backgroundColorForEntry:0];
        }
    }
}

-(void)clearFocusColumn {
    for (UIButton *button in self.buttons) {
        if ([[self.sudoku originalNumberAtTag:button.tag] integerValue] != 0) {
            continue;
        }
        if ([Sudoku columnForTag:button.tag] == [Sudoku columnForTag:self.focusTag]) {
            button.backgroundColor = [UIColor backgroundColorForEntry:0];
        }
    }
}

-(void)arrowButtonTapped:(UIButton *)sender {
    NSInteger tag = sender.tag - 200;
    NSInteger size = Sudoku.size, baseSize = Sudoku.baseSize;
    NSInteger horizontalMove = tag % baseSize - 1, verticalMove = tag / baseSize - 1;
    NSInteger row = self.focusTag / size, column = self.focusTag % size;

    [self clearFocusHighlights];

    do {
        row = (row + verticalMove + size) % size;
        column = (column + horizontalMove + size) % size;
        self.focusTag = row * size + column;

    } while ([[self.sudoku originalNumberAtTag:self.focusTag] integerValue] != 0);

    if (tag == size / 2) {
        [self.sudoku setNumberAtTag:self.focusTag toNumber:0];
        UIButton *button = self.buttons[self.focusTag];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button resetSubviewsWithAlpha:1.0];
    }

    [self drawFocusElements];
}

-(void)digitButtonTapped:(UIButton *)sender {
    [self.sudoku setNumberAtTag:self.focusTag toNumber:sender.tag - 100];
    UIButton *button = self.buttons[self.focusTag];
    [button setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    [button resetSubviewsWithAlpha:0.0];
}

@end
