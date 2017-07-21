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

static NSInteger _size = 9;
static NSInteger _baseSize = 3;

+(NSInteger)size {
    return _size;
}

+(NSInteger)baseSize {
    return _baseSize;
}

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

    if (rowsArray.count < Sudoku.size) {
        puzzle = nil;
        return;
    }

    for (int i = 0; i < Sudoku.size; i++) {
        NSString *row = rowsArray[i];
        [puzzle addObject:[numberFormatter numberFromString:row]];
    }
}

-(NSNumber *)numberAtRow:(NSInteger)row column:(NSInteger)column {
    return [self numberAtRow:row column:column inGrid:self.changingPuzzle];
}

-(NSNumber *)originalNumberAtRow:(NSInteger)row column:(NSInteger)column {
    return [self numberAtRow:row column:column inGrid:self.originalPuzzle];
}

-(NSNumber *)numberAtRow:(NSInteger)row column:(NSInteger)column inGrid:(NSArray *) grid {
    NSInteger rowNumber = [[grid objectAtIndex:row] integerValue];

    for (NSInteger i = Sudoku.size - 1 - column; i > 0; i--) {
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

-(NSSet *)possibleEntriesForTag:(NSInteger)tag {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger i = 1; i <= Sudoku.size; i++) {
        [set addObject:@(i)];
    }

    [self filterEntriesInSet:set basedOnBoxForTag:tag];
    [self filterEntriesInSet:set basedOnRowForTag:tag];
    [self filterEntriesInSet:set basedOnColumnForTag:tag];

    return [set copy];
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnRowForTag:(NSInteger)tag {
    NSInteger row = [Sudoku rowForTag:tag];

    for (NSInteger column = 0; column < Sudoku.size; column++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] != 0) {
            [set removeObject:[self originalNumberAtRow:row column:column]];
        }
    }
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnColumnForTag:(NSInteger)tag {
    NSInteger column = [Sudoku columnForTag:tag];

    for (NSInteger row = 0; row < Sudoku.size; row ++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] != 0) {
            [set removeObject:[self originalNumberAtRow:row column:column]];
        }
    }
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnBoxForTag:(NSInteger)tag {
    NSInteger box = [Sudoku boxForTag:tag];
    NSInteger boxRow = box / Sudoku.baseSize, boxColumn = box % Sudoku.baseSize;
    NSInteger startRow = Sudoku.baseSize * boxRow, startColumn = Sudoku.baseSize * boxColumn;

    for (NSInteger r = 0; r < Sudoku.baseSize; r++) {
        for (NSInteger c = 0; c < Sudoku.baseSize; c++) {
            if ([[self originalNumberAtRow:startRow + r column:startColumn + c] integerValue] != 0) {
                [set removeObject:[self originalNumberAtRow:startRow + r column:startColumn + c]];
            }
        }
    }
}

-(NSSet *)tagsRelevantToTag:(NSInteger)tag {
    NSMutableSet *set = [NSMutableSet set];
    [set addObjectsFromArray:[self tagsInBox:[Sudoku boxForTag:tag]]];
    [set addObjectsFromArray:[self tagsInRow:[Sudoku rowForTag:tag]]];
    [set addObjectsFromArray:[self tagsInRow:[Sudoku columnForTag:tag]]];
    return [set copy];
}

-(NSArray *)tagsInBox:(NSInteger)box {
    NSMutableSet *set = [NSMutableSet set];
    NSInteger boxRow = box / Sudoku.baseSize, boxColumn = box % Sudoku.baseSize;
    NSInteger startRow = boxRow * Sudoku.baseSize, startColumn = boxColumn * Sudoku.baseSize;

    for (NSInteger r = 0; r < Sudoku.baseSize; r++) {
        for (NSInteger c = 0; c < Sudoku.baseSize; c++) {
            if ([[self originalNumberAtRow:startRow + r column:startColumn + c] integerValue] == 0) {
                [set addObject:@((startRow + r) * Sudoku.size + startColumn + c)];
            }
        }
    }

    return [set allObjects];
}

-(NSArray *)tagsInRow:(NSInteger)row {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger column = 0; column < Sudoku.size; column++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] == 0) {
            [set addObject:@(row * Sudoku.size + column)];
        }
    }

    return [set allObjects];
}

-(NSArray *)tagsInColumn:(NSInteger)column {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger row = 0; row < Sudoku.size; row++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] == 0) {
            [set addObject:@(row * Sudoku.size + column)];
        }
    }

    return [set allObjects];
}

+(NSInteger)rowForTag:(NSInteger)tag {
    return tag / Sudoku.size;
}

+(NSInteger)columnForTag:(NSInteger)tag {
    return tag % Sudoku.size;
}

+(NSInteger)boxRowForTag:(NSInteger)tag {
    return tag / Sudoku.size / Sudoku.baseSize;
}

+(NSInteger)boxColumnForTag:(NSInteger)tag {
    return (tag / Sudoku.baseSize) % Sudoku.baseSize;
}

+(NSInteger)boxSubRowForTag:(NSInteger)tag {
    return (tag / Sudoku.size) % Sudoku.baseSize;
}

+(NSInteger)boxSubColumnForTag:(NSInteger)tag {
    return tag % Sudoku.baseSize;
}

+(NSInteger)boxForTag:(NSInteger)tag {
    return [Sudoku boxRowForTag:tag] * Sudoku.baseSize + [Sudoku boxColumnForTag:tag];
}

@end
