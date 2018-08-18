//
//  NSDate+formatter.m
//  Ello
//
//  Created by vd-rahim on 1/15/18.
//  Copyright © 2018 vd-rahim. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate(Formatter)

+ (NSString *)GenerateMessageHistoryDate:(NSDate *)date{
    NSInteger timeDifferenceOfMessageDate = [[NSDate date] timeIntervalSinceDate:date];
    
    if(timeDifferenceOfMessageDate<86400){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        return [formatter stringFromDate:date];
    }else if(timeDifferenceOfMessageDate<604800){
        int day = timeDifferenceOfMessageDate/86400;
        
        //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        //int weekday = [comps weekday];
        
        return [self getDayfromDayIndex:day];
        
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        
        return [formatter stringFromDate:date];
    }
    
}

+ (NSString *)getDayfromDayIndex:(int)index{
    switch (index) {
        case 1:
            return @"Sunday";
        case 2:
            return @"Monday";
        case 3:
            return @"Tuesday";
        case 4:
            return @"Wednesday";
        case 5:
            return @"Thursday";
        case 6:
            return @"Friday";
        case 7:
            return @"Saturday";
        default:
            return @"";
    }
}

@end


