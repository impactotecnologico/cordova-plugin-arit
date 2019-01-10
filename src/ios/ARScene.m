//
//  Scene.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 11/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ARScene.h"
#import "ARApplicationController.h"

@interface ARScene()

@end

@implementation ARScene

+(ARScene*) makeSceneAt: (unsigned long) index ofType: (ARTypeContent) type
{
    ARScene* scene = [[ARScene alloc] init];
    
    [scene setType:type];
    [scene setIndex:index];
    
    [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig * config)
    {
        NSString* nameResource;
        switch (type) {
            case ARTypeContentImage:
                nameResource = [[config imagesAR] objectAtIndex:index];
                break;
            case ARTypeContentVideo:
                nameResource = [[config videosAR] objectAtIndex:index];
                break;
            default:
                break;
        }

        NSString* pathResource = [config pathARResource:nameResource];
        NSURL* urlResource = [NSURL fileURLWithPath:pathResource];
        
        switch (type) {
            case ARTypeContentImage:
                [scene setContent: [[CraftARTrackingContentImage alloc] initWithImageFromURL:urlResource]];
                break;
            case ARTypeContentVideo:
            {
                CraftARTrackingContentVideo* content = [[CraftARTrackingContentVideo alloc] initWithVideoFrom:urlResource];
                [content setHasTransparencyMask:true];
                [content setMuted:false];
                [content setVolume: 1.0];
                [scene setContent: content];
                break;
            }
            default:
                break;
        }
    }];
    
    return scene;
}
@end
