//
//  LrcParser.m
//  MP3PlayerShowingLRConLockedScreen
//
//  Created by JianRongCao on 14-3-17.
//  Copyright (c) 2014年 Suning. All rights reserved.
//

#import "LrcParser.h"

@interface LrcParser ()

- (void)parseLrc:(NSString *)word;

@end

@implementation LrcParser

- (instancetype) init
{
    if (self = [super init]) {
        self.timerArray = [[NSMutableArray alloc] init];
        self.wordArray = [[NSMutableArray alloc] init];
    }
    return  self;
}

- (NSString *)getLrcFile:(NSString *)lrc
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:lrc ofType:@"lrc"];
    return  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)parseLrc:(NSString *)lrc
{
    NSString *lrcContent = [self getLrcFile:lrc];
    NSLog(@"%@",lrcContent);
    if(![lrcContent isEqual:nil]) {
        NSArray *sepArray = [lrcContent componentsSeparatedByString:@"["];
        NSArray *lineArray = [[NSArray alloc] init];
        for(int index = 0; index < sepArray.count; index++) {
            if([sepArray[index] length] > 0) {
                lineArray = [sepArray[index] componentsSeparatedByString:@"]"];
                if (![lineArray[0] isEqualToString:@"\n"]) {
                    [self.timerArray addObject:lineArray[0]];
                    [self.wordArray addObject:lineArray.count > 1 ? lineArray[1] : @""];
                }
            }
        }
    }
}

@end
