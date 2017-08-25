//
//  ARPlugin.m
//  ios
//
//  Created by Roysbert Salinas on 21/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ARPlugin.h"
#import "ARApplicationController.h"
#import "ARConstants.h"
#import "ARAugmentedViewController.h"
#import "ARWaitingViewController.h"

@interface ARPlugin()

@property NSString* action;
@property NSString* lastCallBackId;
@property ARWaitingViewController *waitingView;

@end

@implementation ARPlugin

#pragma mark ViewController

- (void) menu: (CDVInvokedUrlCommand*)command;
{
    [self setLastCallBackId: command.callbackId];
    
    [self setAction: AR_ACTION_MENU];
    
    [self initialize];
    
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [self lastCallBackId]];
}

- (void) bienvenida: (CDVInvokedUrlCommand*)command;
{
    [self setLastCallBackId: command.callbackId];
    
    [self setAction: AR_ACTION_VIDEO];
    
    [self initialize];
    
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [self lastCallBackId]];
    
}

- (void) execute: (CDVInvokedUrlCommand*)command
{
    [self setLastCallBackId: command.callbackId];
    
    if ([command.arguments count] != 1)
    {
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [self lastCallBackId]];
        return;
    }
    
    [self setAction:(NSString *) [command.arguments objectAtIndex:0]];
    
    [self initialize];
    
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [self lastCallBackId]];
}

- (void) initialize
{
    NSLog(@"AR-IT plugin - initialize");
    
    [self setWaitingView: [ARWaitingViewController makeInViewController:[self viewController]]];
    
    [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig *config)  {
        [self didReceiveConfig:config];
    }];
}

- (void)didReceiveConfig: (ARConfig*) config
{
    NSLog(@"AR-IT plugin - DidReceiveConfig");
    
    [[ARApplicationController Instance] getResourcesAndStore:^(NSString *message, float percent) {
        [self didChangeProcessStoreResourceMessage:message percentProcess:percent];
    } callback:^{
        [self didFinishedStoreResource];
    }];
}

- (void)didChangeProcessStoreResourceMessage: (NSString*) message percentProcess:(float) percent
{
    [[self waitingView] setMessage: message];
    [[self waitingView] setPercent: percent];
}

-(void) didFinishedStoreResource
{
    [[self waitingView] dismiss];
    
    ARAugmentedViewController* viewController = [ARAugmentedViewController Instance];
    
    [viewController setAction:[self action]];
    
    
    [self.viewController presentViewController:viewController
                                      animated:YES
                                    completion:^{
                                        
                                    }];
}

@end
