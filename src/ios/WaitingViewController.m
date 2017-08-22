//
//  WaitingViewController.m
//  ios
//
//  Created by Roysbert Salinas on 22/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "WaitingViewController.h"

@interface WaitingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelProcessMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProcessPercent;

@end

@implementation WaitingViewController

#pragma mark Init by Storyboard.
+(WaitingViewController*) makeInViewController: (UIViewController *)parent
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WaitingViewController* viewController = (WaitingViewController*) [storyboard instantiateViewControllerWithIdentifier:@"WaitingView"];
    
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
