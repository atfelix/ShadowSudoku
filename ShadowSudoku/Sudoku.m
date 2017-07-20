//
//  Sudoku.m
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-11.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import "Sudoku.h"

@interface Sudoku ()

@property (nonatomic, strong, readonly) NSMutableArray <NSNumber *> *originalPuzzle;
@property (nonatomic, strong, readwrite) NSMutableArray <NSNumber *> *changingPuzzle;

@end

@implementation Sudoku

-(instancetype)initFromContentsOfURL:(NSURL *)url {
    self = [super init];
    if (self) {
        [self setupPuzzlesFromURL:url];
    }
    return self;
}

-(void)setupPuzzlesFromURL:(NSURL *) url {
    [self setupOriginalPuzzleFromURL:url];
    [self setupChangingPuzzleFromURL:url];
}

-(void)setupOriginalPuzzleFromURL:(NSURL *) url {
    _originalPuzzle = [@[] mutableCopy];
    [self setupPuzzle:_originalPuzzle fromURL:url];
}

-(void)setupChangingPuzzleFromURL:(NSURL *) url {
    _changingPuzzle = [@[] mutableCopy];
    [self setupPuzzle:_changingPuzzle fromURL:url];
}

-(void)setupPuzzle:(NSMutableArray *)puzzle fromURL:(NSURL *)url {
    NSError *error = nil;

    NSString *sudokuString = [NSString stringWithContentsOfURL:url
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];

    if (error) {
        return;
    }

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSArray *rowsArray = [sudokuString componentsSeparatedByString:@"\n"];

    if (rowsArray.count < 10) {
        puzzle = nil;
        return;
    }

    for (int i = 0; i < 9; i++) {
        NSString *row = rowsArray[i];
        [puzzle addObject:[numberFormatter numberFromString:row]];
    }
}

-(NSNumber *)numberAtRow:(NSInteger)row column:(NSInteger)column {
    NSInteger rowNumber = [[self.changingPuzzle objectAtIndex:row] integerValue];

    for (NSInteger i = 8 - column; i > 0; i--) {
        rowNumber /= 10;
    }

    return @(rowNumber % 10);
}

-(NSNumber *)originalNumberAtRow:(NSInteger)row column:(NSInteger)column {
    NSInteger rowNumber = [[self.originalPuzzle objectAtIndex:row] integerValue];

    for (NSInteger i = 8 - column; i > 0; i--) {
        rowNumber /= 10;
    }

    return @(rowNumber % 10);
}


-(NSNumber *)numberAtTag:(NSInteger)tag {
    return [self numberAtRow:[Sudoku rowForTag:tag]
                      column:[Sudoku columnForTag:tag]];
}

-(void)setNumberAtTag:(NSInteger)tag toNumber:(NSInteger)number {
    if ([[self originalNumberAtTag:tag] integerValue] != 0) {
        return;
    }

    [self setNumberAtRow:[Sudoku rowForTag:tag]
                  column:[Sudoku columnForTag:tag]
                toNumber:number];
}

-(void)setNumberAtRow:(NSInteger)row column:(NSInteger)column toNumber:(NSInteger)number {
    NSInteger numberAtRow = [[self.changingPuzzle objectAtIndex:row] integerValue];
    NSInteger factorOfTen = 1;

    for (NSInteger i = 8 - column; i > 0; i--) {
        factorOfTen *= 10;
    }

    numberAtRow -= factorOfTen * [[self numberAtRow:row column:column] integerValue];
    numberAtRow += factorOfTen * number;
    self.changingPuzzle[row] = @(numberAtRow);
}

-(NSNumber *)originalNumberAtTag:(NSInteger)tag {
    return [self originalNumberAtRow:[Sudoku rowForTag:tag]
                              column:[Sudoku columnForTag:tag]];
}

+(NSInteger)rowForTag:(NSInteger)tag {
    return tag / 9;
}

+(NSInteger)columnForTag:(NSInteger)tag {
    return tag % 9;
}

+(NSInteger)boxRowForTag:(NSInteger)tag {
    return tag / 27;
}

+(NSInteger)boxColumnForTag:(NSInteger)tag {
    return (tag / 3) % 3;
}

+(NSInteger)boxSubRowForTag:(NSInteger)tag {
    return (tag / 9) % 3;
}

+(NSInteger)boxSubColumnForTag:(NSInteger)tag {
    return tag % 3;
}

+(NSInteger)boxForTag:(NSInteger)tag {
    return [Sudoku boxRowForTag:tag] * 3 + [Sudoku boxColumnForTag:tag];
}

@end
