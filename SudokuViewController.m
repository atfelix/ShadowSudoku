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
#import "UIView+GridCell.h"

@interface SudokuViewController ()

@property (nonatomic, strong) Sudoku *sudoku;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SudokuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSudoku];
    [self setupSudokuGrid];
    [self setupDigitButtons];
    [self setupArrowButtons];
}

-(void)setupSudoku {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"n00b"
                                                     ofType:@"sudoku"];
    self.sudoku = [[Sudoku alloc] initFromContentsOfURL:[NSURL fileURLWithPath:path]];
}

-(void)setupSudokuGrid {
    [self setupGridView];

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UIView *gridCellView = [UIView viewWithSudokuCellStyleInSuperView:self.view
                                                                     atBoxRow:i
                                                                    boxColumn:j];
            [self.gridView addSubview:gridCellView];
            [self setupBoxAtRow:i andColumn:j inGridView:gridCellView];
        }
    }
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

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            NSInteger tag = (row * 3 + i) * 9 + column * 3 + j;
            UIButton *button = [UIButton buttonWithSudokuStyleForTag:tag
                                                         sudokuEntry:[[self.sudoku numberAtTag:tag] integerValue]
                                                              inGrid:gridCellView];
            [button addTarget:self
                       action:@selector(sudokuButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
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

    for (NSInteger digit = 1; digit < 10; digit++) {
        UIButton *button = [UIButton inputButtonForDigit:digit inGrid:gridCellView];
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

    for (NSInteger arrowInt = 0; arrowInt < 9; arrowInt++) {
        UIButton *button = [UIButton arrowButtonForInteger:arrowInt inGrid:gridCellView];
        [gridCellView addSubview:button];
    }
}

-(void)sudokuButtonTapped:(UIButton *)sender {
    NSLog(@"%@", @(sender.tag));
}

@end
