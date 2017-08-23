//
//  ApplicationController.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 12/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARConfig.h"
#import "ARScene.h"
@interface ARApplicationController : NSObject

@property BOOL continueProccess;

- (void) getConfigOnSuccess:(void(^)(ARConfig*)) handler;
- (void) getResourcesAndStore:(void(^)(NSString* message, float percent)) handler callback: (void(^)()) onFinished;
- (ARScene*) getSceneAt: (unsigned long) index ofType: (ARTypeContent) type;
-(void) clearScenesOfType: (ARTypeContent) type;

+(ARApplicationController*) Instance;
@end
