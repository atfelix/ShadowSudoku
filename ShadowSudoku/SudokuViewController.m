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
@property (nonatomic, strong) NSMutableArray *digitButtons;

@end

@implementation SudokuViewController


#pragma mark - View Life Cycle


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

    for (NSInteger i = 0; i < self.sudoku.baseSize; i++) {
        for (NSInteger j = 0; j < self.sudoku.baseSize; j++) {
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

-(void)setupDigitButtons {
    self.digitButtons = [[NSMutableArray alloc] init];
    UIView *gridCellView = [UIView viewWithButtonGridCellStyleInSuperView:self.view
                                                                 atBoxRow:0
                                                                boxColumn:0];
    gridCellView.frame = CGRectMake(10,
                                    self.view.bounds.size.height - 10 - gridCellView.frame.size.height,
                                    gridCellView.frame.size.height,
                                    gridCellView.frame.size.width);
    [self.view addSubview:gridCellView];

    for (NSInteger digit = 1; digit < self.sudoku.size + 1; digit++) {
        UIButton *button = [UIButton inputButtonForDigit:digit inGrid:gridCellView];
        [button addTarget:self
                   action:@selector(digitButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.digitButtons addObject:button];
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

    for (NSInteger arrowInt = 0; arrowInt < self.sudoku.size; arrowInt++) {
        UIButton *button = [UIButton arrowButtonForInteger:arrowInt inGrid:gridCellView];
        [button addTarget:self
                   action:@selector(arrowButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [gridCellView addSubview:button];
    }
}

-(void)setInitialFocus {
    for (NSInteger tag = 0; tag < self.sudoku.size * self.sudoku.size; tag++) {
        if ([[self.sudoku numberAtTag:tag] integerValue] == 0) {
            self.focusTag = tag;
            break;
        }
    }
}


#pragma mark - Update appearance methods


-(void)updateDigitButtonsForTag:(NSInteger)tag {
    for (NSInteger i = 0; i < self.digitButtons.count; i++) {
        UIButton *button = self.digitButtons[i];
        [button updateDigitButtonInSudoku:self.sudoku forTag:tag];
    }
}


#pragma mark - View Life Cycle Helper methods


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

    for (NSInteger i = 0; i < self.sudoku.baseSize; i++) {
        for (NSInteger j = 0; j < self.sudoku.baseSize; j++) {
            NSInteger tag = (row * self.sudoku.baseSize + i) * self.sudoku.size + column * self.sudoku.baseSize + j;
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


#pragma mark - Focus tag methods


-(void)setFocusTag:(NSInteger)focusTag {
    [self clearFocusHighlights];
    _focusTag = focusTag;
    [self drawFocusElements];
    [self updateDigitButtonsForTag:focusTag];
}

-(void)drawFocusElements {
    [self drawFocusRow];
    [self drawFocusColumn];
    [self drawFocusBox];
    [self drawFocusBackground];
}

-(void)drawFocusBox {
    [self colorButtonTags:[self.sudoku tagsInBox:[self.sudoku boxForTag:self.focusTag]]
                    color:[UIColor highlightColorForBox]];
}

-(void)drawFocusRow {
    [self colorButtonTags:[self.sudoku tagsInRow:[self.sudoku rowForTag:self.focusTag]]
                    color:[UIColor highlightColorForRow]];
}

-(void)drawFocusColumn {
    [self colorButtonTags:[self.sudoku tagsInColumn:[self.sudoku columnForTag:self.focusTag]]
                    color:[UIColor highlightColorForColumn]];
}

-(void)drawFocusBackground {
    if ([[self.sudoku originalNumberAtTag:self.focusTag] integerValue] == 0) {
        ((UIButton *)self.buttons[self.focusTag]).backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    }
}

-(void)clearFocusHighlights {
    [self clearFocusBox];
    [self clearFocusRow];
    [self clearFocusColumn];
}

-(void)clearFocusBox {
    [self colorButtonTags:[self.sudoku tagsInBox:[self.sudoku boxForTag:self.focusTag]]
                    color:[UIColor unHighlightedColor]];
}

-(void)clearFocusRow {
    [self colorButtonTags:[self.sudoku tagsInRow:[self.sudoku rowForTag:self.focusTag]]
                    color:[UIColor unHighlightedColor]];
}

-(void)clearFocusColumn {
    [self colorButtonTags:[self.sudoku tagsInColumn:[self.sudoku columnForTag:self.focusTag]]
                    color:[UIColor unHighlightedColor]];
}

-(void)colorButtonTags:(NSArray <NSNumber *> *)tags color:(UIColor *)color {
    for (NSNumber* tag in tags) {
        ((UIButton *)self.buttons[[tag integerValue]]).backgroundColor = color;
    }
}


#pragma mark - Button actions


-(void)sudokuButtonTapped:(UIButton *)sender {
    if ([[self.sudoku originalNumberAtTag:sender.tag] integerValue] != 0) {
        return;
    }
    self.focusTag = sender.tag;
}

-(void)arrowButtonTapped:(UIButton *)sender {
    self.focusTag = [self findNextValidTagFromTag:self.focusTag inDirection:sender.tag];
    [self clearCellIfNeeded:sender];
}

-(void)digitButtonTapped:(UIButton *)sender {
    [self.sudoku setNumberAtTag:self.focusTag toNumber:sender.tag];
    UIButton *button = self.buttons[self.focusTag];
    [button setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    [button resetSubviewsWithAlpha:0.0];

    for (NSNumber *tag in [self.sudoku tagsRelevantToTag:self.focusTag]) {
        UIButton *button = self.buttons[[tag integerValue]];
        for (UIView *view in button.subviews) {
            if (view.tag == sender.tag) {
                ((UILabel *)view).text = @"✖";
                ((UILabel *)view).font = [UIFont systemFontOfSize:10];
            }
        }
    }
}


#pragma mark - Helper methods


-(NSInteger)findNextValidTagFromTag:(NSInteger)tag inDirection:(NSInteger)direction {
    NSInteger size = self.sudoku.size, baseSize = self.sudoku.baseSize;
    NSInteger horizontalMove = direction % baseSize - 1, verticalMove = direction / baseSize - 1;
    NSInteger row = tag / size, column = tag % size;

    do {
        row = (row + verticalMove + size) % size;
        column = (column + horizontalMove + size) % size;
        tag = row * size + column;
    } while ([[self.sudoku originalNumberAtTag:tag] integerValue] != 0);

    return tag;
}

-(void)clearCellIfNeeded:(UIButton *)sender {
    if (sender.tag == self.sudoku.size / 2) {
        [self.sudoku setNumberAtTag:self.focusTag toNumber:0];
        UIButton *button = self.buttons[self.focusTag];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button resetSubviewsWithAlpha:1.0];
    }
}

@end
