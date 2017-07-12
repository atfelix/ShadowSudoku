//
//  SudokuViewController.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-11.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "SudokuViewController.h"

#import "Sudoku.h"

@interface SudokuViewController ()

@property (nonatomic, strong) Sudoku *sudoku;
@property (nonatomic, strong) UIView *gridView;

@end

@implementation SudokuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSudoku];
    [self setupSudokuGrid];
}

-(void)setupSudoku {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"debug"
                                                     ofType:@"sudoku"];
    self.sudoku = [[Sudoku alloc] initFromContentsOfURL:[NSURL fileURLWithPath:path]];
}

-(void)setupSudokuGrid {
    [self setupGridView];
    CGFloat width = (self.view.bounds.size.width - 20) / 3;

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(j * width, i * width, width, width)];
            view.userInteractionEnabled = YES;
            view.layer.borderColor = [UIColor blackColor].CGColor;
            view.layer.borderWidth = 2.0;
            [self.gridView addSubview:view];
            [self setupBoxAtRow:i andColumn:j inGridView:view];
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
    [gridView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [gridView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10.0].active = YES;
    [gridView.widthAnchor constraintEqualToConstant:self.view.bounds.size.width - 100].active = YES;
    [gridView.heightAnchor constraintEqualToAnchor:self.gridView.widthAnchor].active = YES;
}

-(void)setupBoxAtRow:(NSInteger)row andColumn:(NSInteger)column inGridView:(UIView *)gridView {
    CGFloat width = gridView.bounds.size.width / 3;

    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(j * width, i * width, width, width)];
            label.userInteractionEnabled = YES;
            label.layer.borderColor = [UIColor redColor].CGColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = (row * 3 + i) * 9 + column * 3 + j;
            label.text = [NSString stringWithFormat:@"%@", @((row * 3 + i) * 9 + column * 3 + j)];
            label.layer.borderWidth = 2.0;
            [gridView addSubview:label];
        }
    }
}

@end
