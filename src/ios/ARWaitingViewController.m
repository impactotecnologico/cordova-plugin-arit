//
//  WaitingViewController.m
//  ios
//
//  Created by Roysbert Salinas on 22/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ARWaitingViewController.h"

@interface ARWaitingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelProcessMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProcessPercent;

@end

@implementation ARWaitingViewController

#pragma mark Init by Storyboard.
+(ARWaitingViewController*) makeInViewController: (UIViewController *)parent
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"ARMain" bundle:nil];
    ARWaitingViewController* viewController = (ARWaitingViewController*) [storyboard instantiateViewControllerWithIdentifier:@"WaitingView"];
    
    [parent addChildViewController:viewController];
    viewController.view.frame = [[parent view] frame];
    
    [[parent view] addSubview: [viewController view]];
    [viewController didMoveToParentViewController: parent];
    return viewController;
}
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismiss
{
    [[self view] removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setMessage: (NSString*) message
{
    [[self labelProcessMessage] setText:message];
}

-(void) setPercent: (float) percent
{
    [[self labelProcessPercent] setText: [NSString stringWithFormat:@"%.02f", percent]];
}
- (void)displayContentController:(UIViewController *)content {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
