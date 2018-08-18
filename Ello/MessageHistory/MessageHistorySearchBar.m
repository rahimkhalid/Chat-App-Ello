//
//  MessageHistorySearchBar.m
//  Ello
//
//  Created by vd-rahim on 11/11/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "MessageHistorySearchBar.h"

@implementation MessageHistorySearchBar

- (void)awakeFromNib{
    [super awakeFromNib];
    [_searchBar setImage:[UIImage imageNamed:@"searchIcon"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];

}

@end
