//
//  MainViewController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//


#import "Constants.h"
#import "MainViewController.h"
#import "AugmentedViewController.h"
#import "ApplicationController.h"
#import "WaitingViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonMenu;
@property (weak, nonatomic) IBOutlet UIButton *buttonVideo;
@property WaitingViewController *waitingView;


@property NSString *action;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAction: ACTION_MENU];
    
    [self setWaitingView: [WaitingViewController makeInViewController:self]];
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config *config)  {
        [self didReceiveConfig:config];
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[[self navigationController] navigationBar] topItem] setTitle:@"TecnoBoda"];
}

- (void)didReceiveConfig: (Config*) config
{
    [[ApplicationController Instance] getResourcesAndStore:^(NSString *message, float percent) {
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
        [self setAction: ACTION_VIDEO];
    else
        [self setAction: ACTION_MENU];
    
    AugmentedViewController *view = [AugmentedViewController Instance];
    [view setAction: [self action]];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
