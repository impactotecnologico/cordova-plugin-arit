//
//  ARPlugin.h
//  objectivec
//
//  Created by Roysbert Salinas on 17/8/17.
//  Copyright © 2017 Roysbert Salinas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface ARPlugin : CDVPlugin

- (void) execute: (CDVInvokedUrlCommand*)command;

@end
