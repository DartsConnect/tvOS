//
//  BonjourBrowserService.h
//  BonjourBrowserService
//
//  Created by Calvin Cheng on 1/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#ifndef BonjourBrowserService_BonjourBrowserService_h
#define BonjourBrowserService_BonjourBrowserService_h

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BonjourBrowserStatus) {
    BONJOURBROWSERSTOPPED,
    BONJOURBROWSERSEARCHING
};

#define BONJOURBROWSERNOTIFICATION @"bonjourBrowserChange"

@interface BonjourBrowserService : NSObject <NSNetServiceBrowserDelegate>

@property int status;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (strong, nonatomic) NSMutableArray *services;

-(id)startBrowsingForType:(NSString *)type;
-(void)stopBrowsing;

@end

#endif
