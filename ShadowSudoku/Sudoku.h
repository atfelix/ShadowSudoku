//
//  Sudoku.h
//  ShadowSudoku
//
//  Created by atfelix on 2017-07-11.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sudoku : NSObject

-(instancetype)initFromContentsOfURL: (NSURL *)url;
-(NSNumber *)numberAtTag:(NSInteger)tag;
-(NSNumber *)originalNumberAtTag:(NSInteger)tag;
-(void)setNumberAtTag:(NSInteger)tag toNumber:(NSInteger)number;

+(NSInteger)rowForTag:(NSInteger)tag;
+(NSInteger)columnForTag:(NSInteger)tag;
+(NSInteger)boxRowForTag:(NSInteger)tag;
+(NSInteger)boxColumnForTag:(NSInteger)tag;
+(NSInteger)boxSubRowForTag:(NSInteger)tag;
+(NSInteger)boxSubColumnForTag:(NSInteger)tag;
+(NSInteger)boxForTag:(NSInteger)tag;

@end
