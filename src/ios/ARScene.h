//
//  Scene.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 11/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CraftARAugmentedRealitySDK/CraftARSDK.h>
#import <CraftARAugmentedRealitySDK/CraftARCloudRecognition.h>
#import <CraftARAugmentedRealitySDK/CraftARTracking.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContent.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContentImage.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContentVideo.h>

#import "ARDomains.h"

@interface ARScene : NSObject

@property ARTypeContent type;
@property unsigned long index;
@property CraftARTrackingContent* content;

+(ARScene*) makeSceneAt: (unsigned long) index ofType: (ARTypeContent) type;

@end
