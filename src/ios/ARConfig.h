//
//  Config.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARBaseApiController.h"

@interface ARConfig : NSObject

@property NSString* titulo;
@property NSString* fechaTexto;
@property NSString* color;
@property NSString* colorRosa;
@property NSString* iniciales;
@property NSNumber* shutdown;
@property NSString* urlBase;
@property NSNumber* delay;
@property NSString* arCollection;
@property NSString* arMobileDirectory;

@property NSArray* items;
@property NSArray* imagesAR;
@property NSArray* videosAR;
@property NSArray* minis;


-(NSString*) pathARResource: (NSString*) nameResource;
+(ARConfig*) makeWith: (NSDictionary*)data;

@end
