//
//  ItemInfo.m
//  AudioDownloader
//
//  Created by zhangguang on 15/12/11.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "ItemInfo.h"

@implementation ItemInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.state = [[aDecoder decodeObjectForKey:@"state"] integerValue];
        self.progress = [[aDecoder decodeObjectForKey:@"progress"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:@(self.state) forKey:@"state"];
    [aCoder encodeObject:@(self.progress) forKey:@"progress"];
}

- (void)titleTextTrim {
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"\t\n"];
    self.title = [self.title stringByTrimmingCharactersInSet:charSet];
}

- (void)resetState {
    if (self.state == Running) {
        self.state = Suspended;
    }
}

@end
