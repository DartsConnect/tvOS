//
//  BonjourBrowserService.m
//  BonjourBrowserService
//
//  Created by Calvin Cheng on 1/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BonjourBrowserService.h"

@implementation BonjourBrowserService : NSObject

-(id)init {
    self = [super init];
    if (self) {
        self.services = [[NSMutableArray alloc] init];
        self.status = BONJOURBROWSERSTOPPED;
    }
    return self;
}

-(id)startBrowsingForType:(NSString *)type {
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:type inDomain:@""];    // @"" implies searching local domain only
    self.status = BONJOURBROWSERSEARCHING;
    return self;
}

-(NSMutableArray *)discoveredServices {
    return self.services;
}

-(void)stopBrowsing {
    NSLog(@"Stop browsing");
    [self.serviceBrowser stop];
    [self.services removeAllObjects];
}

// 5 NSNetServiceBrowser delegate methods during NSNetServiceBrowser object's lifecycle.
-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"Begin searching");
    self.status = BONJOURBROWSERSEARCHING;
    [self changeNotification];
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"Did stop search");
    self.status = BONJOURBROWSERSTOPPED;
    [self changeNotification];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"Did not search");
    self.status = BONJOURBROWSERSTOPPED;
    [self changeNotification];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"Found the service");
    [self.services addObject:aNetService];
    NSLog(@"%@", aNetService.name);
    if (!moreComing) {
        [self changeNotification];
    }
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"Service removed");
    [self.services removeObject:aNetService];
    if (!moreComing) {
        [self changeNotification];
    }
}
     
-(void)changeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:BONJOURBROWSERNOTIFICATION object:nil];
}

@end