//
//  BonjourResolverService.h
//  BonjourBrowserService
//
//  Created by Calvin Cheng on 1/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#ifndef BonjourBrowserService_BonjourResolverService_h
#define BonjourBrowserService_BonjourResolverService_h

#import <Foundation/Foundation.h>

#define BONJOURRESOLVERNOTIFICATION @"resolverComplete"

@interface BonjourResolverService : NSObject <NSNetServiceDelegate>

-(void)resolveService:(NSNetService *)service;

@end

#endif
