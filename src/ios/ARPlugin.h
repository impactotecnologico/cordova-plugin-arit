//
//  ARPlugin.h
//  ios
//
//  Created by Roysbert Salinas on 21/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface ARPlugin : CDVPlugin

- (void) execute: (CDVInvokedUrlCommand*)command;
- (void) menu: (CDVInvokedUrlCommand*)command;
- (void) bienvenido: (CDVInvokedUrlCommand*)command;

@end
