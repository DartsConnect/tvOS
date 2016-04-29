//
//  BonjourResolverService.m
//  BonjourBrowserService
//
//  Created by Calvin Cheng on 1/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BonjourResolverService.h"

@implementation BonjourResolverService : NSObject

-(void)resolveService:(NSNetService *)service {
    NSLog(@"Let's resolve the service");
    [service setDelegate:self];
    [service resolveWithTimeout:5.0];
}

// 2 delegate methods from NSNetService
-(void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"Service did resolve address");
    NSArray *addresses = sender.addresses;
    [[NSNotificationCenter defaultCenter] postNotificationName:BONJOURRESOLVERNOTIFICATION object:addresses];
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Service did not resolve");
    [[NSNotificationCenter defaultCenter] postNotificationName:BONJOURRESOLVERNOTIFICATION object:nil];
}

@end