//
//  MainViewController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//


#import "ARConstants.h"
#import "ARMainViewController.h"
#import "ARAugmentedViewController.h"
#import "ARApplicationController.h"
#import "ARWaitingViewController.h"

@interface ARMainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonMenu;
@property (weak, nonatomic) IBOutlet UIButton *buttonVideo;
@property ARWaitingViewController *waitingView;


@property NSString *action;
@end

@implementation ARMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAction: AR_ACTION_MENU];
    
    [self setWaitingView: [ARWaitingViewController makeInViewController:self]];
    
    [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig *config)  {
        [self didReceiveConfig:config];
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[[self navigationController] navigationBar] topItem] setTitle:@"TecnoBoda"];
}

- (void)didReceiveConfig: (ARConfig*) config
{
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onTapButton:(UIButton*)sender
{
    if ([sender isEqual: [self buttonVideo]])
        [self setAction: AR_ACTION_VIDEO];
    else
        [self setAction: AR_ACTION_MENU];
    
    ARAugmentedViewController *view = [ARAugmentedViewController Instance];
    [view setAction: [self action]];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
