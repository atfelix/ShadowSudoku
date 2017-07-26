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


#pragma mark - Initialization


-(instancetype)initFromContentsOfURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _size = 9;
        _baseSize = 3;
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

    if (sudokuString.length != _size * _size + 1) {
        puzzle = nil;
        return;
    }

    for (int i = 0; i < _size * _size; i++) {
        [puzzle addObject:[numberFormatter numberFromString:[NSString stringWithFormat:@"%c", [sudokuString characterAtIndex:i]]]];
    }
}


#pragma mark - Accessor methods for entries in puzzles


-(NSNumber *)originalNumberAtTag:(NSInteger)tag {
    return [self.originalPuzzle objectAtIndex:tag];
}

-(NSNumber *)numberAtTag:(NSInteger)tag {
    return [self.changingPuzzle objectAtIndex:tag];
}

-(NSNumber *)numberAtRow:(NSInteger)row column:(NSInteger)column {
    return [self numberAtRow:row column:column inGrid:self.changingPuzzle];
}

-(NSNumber *)originalNumberAtRow:(NSInteger)row column:(NSInteger)column {
    return [self numberAtRow:row column:column inGrid:self.originalPuzzle];
}

-(NSNumber *)numberAtRow:(NSInteger)row column:(NSInteger)column inGrid:(NSArray *) grid {
    return grid[[self indexForRow:row column:column]];
}


#pragma mark - Mutator methods for entries in puzzles


-(void)setNumberAtTag:(NSInteger)tag toNumber:(NSInteger)number {
    if ([[self originalNumberAtTag:tag] integerValue] != 0) {
        return;
    }

    self.changingPuzzle[tag] = @(number);
}

-(void)setNumberAtRow:(NSInteger)row column:(NSInteger)column toNumber:(NSInteger)number {
    self.changingPuzzle[[self indexForRow:row column:column]] = @(number);
}


#pragma mark - Allowable entries


-(NSSet *)allowableEntriesForTag:(NSInteger)tag {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger i = 1; i <= self.size; i++) {
        [set addObject:@(i)];
    }

    [self filterEntriesInSet:set basedOnBoxForTag:tag];
    [self filterEntriesInSet:set basedOnRowForTag:tag];
    [self filterEntriesInSet:set basedOnColumnForTag:tag];

    return [set copy];
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnRowForTag:(NSInteger)tag {
    NSInteger row = [self rowForTag:tag];

    for (NSInteger column = 0; column < self.size; column++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] != 0) {
            [set removeObject:[self originalNumberAtRow:row column:column]];
        }
    }
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnColumnForTag:(NSInteger)tag {
    NSInteger column = [self columnForTag:tag];

    for (NSInteger row = 0; row < self.size; row ++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] != 0) {
            [set removeObject:[self originalNumberAtRow:row column:column]];
        }
    }
}

-(void)filterEntriesInSet:(NSMutableSet *)set basedOnBoxForTag:(NSInteger)tag {
    NSInteger box = [self boxForTag:tag];
    NSInteger boxRow = box / self.baseSize, boxColumn = box % self.baseSize;
    NSInteger startRow = self.baseSize * boxRow, startColumn = self.baseSize * boxColumn;

    for (NSInteger r = 0; r < self.baseSize; r++) {
        for (NSInteger c = 0; c < self.baseSize; c++) {
            if ([[self originalNumberAtRow:startRow + r column:startColumn + c] integerValue] != 0) {
                [set removeObject:[self originalNumberAtRow:startRow + r column:startColumn + c]];
            }
        }
    }
}


#pragma mark - Related Tags


-(NSSet *)tagsRelevantToTag:(NSInteger)tag {
    NSMutableSet *set = [NSMutableSet set];
    [set addObjectsFromArray:[self tagsInBox:[self boxForTag:tag]]];
    [set addObjectsFromArray:[self tagsInRow:[self rowForTag:tag]]];
    [set addObjectsFromArray:[self tagsInRow:[self columnForTag:tag]]];
    return [set copy];
}

-(NSArray *)tagsInBox:(NSInteger)box {
    NSMutableSet *set = [NSMutableSet set];
    NSInteger boxRow = box / self.baseSize, boxColumn = box % self.baseSize;
    NSInteger startRow = boxRow * self.baseSize, startColumn = boxColumn * self.baseSize;

    for (NSInteger r = 0; r < self.baseSize; r++) {
        for (NSInteger c = 0; c < self.baseSize; c++) {
            if ([[self originalNumberAtRow:startRow + r column:startColumn + c] integerValue] == 0) {
                [set addObject:@((startRow + r) * self.size + startColumn + c)];
            }
        }
    }

    return [set allObjects];
}

-(NSArray *)tagsInRow:(NSInteger)row {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger column = 0; column < self.size; column++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] == 0) {
            [set addObject:@(row * self.size + column)];
        }
    }

    return [set allObjects];
}

-(NSArray *)tagsInColumn:(NSInteger)column {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger row = 0; row < self.size; row++) {
        if ([[self originalNumberAtRow:row column:column] integerValue] == 0) {
            [set addObject:@(row * self.size + column)];
        }
    }

    return [set allObjects];
}


#pragma mark - Information methods


-(NSInteger)rowForTag:(NSInteger)tag {
    return tag / self.size;
}

-(NSInteger)columnForTag:(NSInteger)tag {
    return tag % self.size;
}

-(NSInteger)boxRowForTag:(NSInteger)tag {
    return tag / self.size / self.baseSize;
}

-(NSInteger)boxColumnForTag:(NSInteger)tag {
    return (tag / self.baseSize) % self.baseSize;
}

-(NSInteger)boxSubRowForTag:(NSInteger)tag {
    return (tag / self.size) % self.baseSize;
}

-(NSInteger)boxSubColumnForTag:(NSInteger)tag {
    return tag % self.baseSize;
}

-(NSInteger)boxForTag:(NSInteger)tag {
    return [self boxRowForTag:tag] * self.baseSize + [self boxColumnForTag:tag];
}

-(NSInteger)indexForRow:(NSInteger)row column:(NSInteger)column {
    return row * self.size + column;
}

@end
