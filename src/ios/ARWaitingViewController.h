//
//  WaitingViewController.h
//  ios
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARWaitingViewController : UIViewController

-(void) dismiss;
-(void) setMessage: (NSString*) message;
-(void) setPercent: (float) percent;

+(ARWaitingViewController*) makeInViewController: (UIViewController *)parent;

@end
