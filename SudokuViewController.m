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

@interface SudokuViewController ()

@property (nonatomic, strong) Sudoku *sudoku;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SudokuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSudoku];
    [self setupSudokuGrid];
}

-(void)setupSudoku {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"n00b"
                                                     ofType:@"sudoku"];
    self.sudoku = [[Sudoku alloc] initFromContentsOfURL:[NSURL fileURLWithPath:path]];
}

-(void)setupSudokuGrid {
    [self setupGridView];
    CGFloat width = (self.view.bounds.size.width - 20) / 3;

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UIView *gridCellView = [[UIView alloc] initWithFrame:CGRectMake(j * width, i * width, width, width)];
            [self setupView:gridCellView
        withUserInteraction:YES
            withBorderColor:[UIColor grayColor]
                borderWidth:2.5
            backgroundColor:[UIColor clearColor]];
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

-(void)setupView:(UIView *)view withUserInteraction:(BOOL)userInteraction withBorderColor:(UIColor *)color borderWidth:(CGFloat)width backgroundColor:(UIColor *)bgColor {
    view.userInteractionEnabled = userInteraction;
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
    view.backgroundColor = bgColor;
}

-(void)setupSudokuButton:(UIButton *)button withAlignment:(NSTextAlignment)alignment atBoxRow:(NSInteger)row boxColumn:(NSInteger)column subRow:(NSInteger)subRow subColumn:(NSInteger)subColumn {
    button.titleLabel.textAlignment = alignment;
    button.tag = (row * 3 + subRow) * 9 + column * 3 + subColumn;
    [button setTitle:[NSString stringWithFormat:@"%@", [self.sudoku numberAtTag:button.tag]]
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(sudokuButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
}

-(void)sudokuButtonTapped:(UIButton *)sender {
    NSLog(@"%@", @(sender.tag));
}

@end
