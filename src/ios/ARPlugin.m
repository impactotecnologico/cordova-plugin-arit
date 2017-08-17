//
//  ARPlugin.m
//  objectivec
//
//  Created by Roysbert Salinas on 17/8/17.
//  Copyright © 2017 Roysbert Salinas. All rights reserved.
//

#import "ARPlugin.h"
#import "ApplicationController.h"
#import "Constants.h"
#import "AugmentedViewController.h"

@interface ARPlugin()

@property NSString* action;

@end

@implementation ARPlugin

#pragma mark ViewController
- (void) execute: (CDVInvokedUrlCommand*)command
{
    NSLog(@"AR-IT plugin - StarLoad");
    
    if ([command.arguments count] != 1){
        [self sentError:command.callbackId];
        return;
    }
    NSDictionary *dict = [command.arguments objectAtIndex:0];
    
    [self setAction:(NSString *) [dict objectForKey:@"action"]];
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config *config)  {
        [self didReceiveConfig:config];
    }];
}

- (void)didReceiveConfig: (Config*) config
{
    NSLog(@"AR-IT plugin - DidReceiveConfig");
    
    [[ApplicationController Instance] getResourcesAndStore:^(NSString *message, float percent) {
        [self didChangeProcessStoreResourceMessage:message percentProcess:percent];
    } callback:^{
        [self didFinishedStoreResource];
    }];
}

- (void)didChangeProcessStoreResourceMessage: (NSString*) message percentProcess:(float) percent
{
    NSLog(@"AR-IT plugin - %@ : %.02f%", message, percent);
}

-(void) didFinishedStoreResource
{
    AugmentedViewController* viewController = [AugmentedViewController Instance];
    
    [viewController setAction:[self action]];
    
    
    [self.viewController presentViewController:viewController
                                      animated:YES
                                    completion:^{
                                        [self sentSuccess:command.callbackId];
                                    }];
}

@end
