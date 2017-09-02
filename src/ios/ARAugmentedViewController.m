//
//  AugmentedViewController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ARAugmentedViewController.h"
#import "ARApplicationController.h"
#import "ARViewUtils.h"
#import "ARConstants.h"

@interface ARAugmentedViewController() <CraftARSDKProtocol, CraftARContentEventsProtocol, SearchProtocol, CraftARTrackingEventsProtocol>

@property CraftARSDK *sdk;
@property CraftARCloudRecognition *cloudRecognition;
@property CraftARTracking *tracking;
@property CraftARItemAR *currentItem;

@property unsigned long currentIndex;
@property unsigned long countResources;
@property ARTypeContent currentTypeContent;

@property ARScene* currentScene;
@property CraftARTrackingContent* nextButton;
@property CraftARTrackingContent* prevButton;
@property CraftARTrackingContent* cart;

@property (weak, nonatomic) IBOutlet UIView *viewVideoPreview;
@property (weak, nonatomic) IBOutlet UIView *viewScanOverlay;
@property (weak, nonatomic) IBOutlet UIView *viewBack;

@property (weak, nonatomic) IBOutlet UIView *viewInfoDialog;
@property (weak, nonatomic) IBOutlet UILabel *labelInfoMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageInfoReference;
@property (weak, nonatomic) IBOutlet UIView *viewInfoBackground;

@property (weak, nonatomic) IBOutlet UILabel *labelScanning;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;

@property ARConfig* config;
@property BOOL isVisibleCard;

@end

@implementation ARAugmentedViewController

@synthesize sdk;
@synthesize cloudRecognition;
@synthesize tracking;
@synthesize currentItem;

#pragma mark Init by Storyboard.
+(ARAugmentedViewController*) Instance
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"ARMain" bundle:nil];
    ARAugmentedViewController* augmentedViewController = (ARAugmentedViewController*) [storyboard instantiateViewControllerWithIdentifier:@"AugmentedView"];
    return augmentedViewController;
}
#pragma mark -

- (void)viewDidLoad
{
    NSLog(@"AugmentedView for : %@", [self action]);
    
    [super viewDidLoad];
    
    [[self labelScanning] setText:AR_TEXT_LABEL_SCANNING];
    [[self buttonBack]  setTitle:AR_TEXT_BUTTON_BACK forState:UIControlStateNormal];
    
    [self setCurrentIndex:0];
    [self setIsVisibleCard:NO];
    
    [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig * config)
     {
         [self setConfig:config];
     }];
    
    [[ARApplicationController Instance] setContinueProccess:YES];
    
    [[self viewInfoBackground] setBackgroundColor:[UIColor whiteColor]];
    if ([[self action] isEqualToString: AR_ACTION_VIDEO])
    {
        [self setCurrentTypeContent:ARTypeContentVideo];
        [self setCountResources: [[[self config] videosAR] count]];
        [[self labelInfoMessage] setText: AR_TEXT_HELP_WELCOME];
        NSString *path = [[self config] pathARResource:@"bienvenida_mini.jpg"];
        [[self imageInfoReference] setImage: [[UIImage alloc] initWithContentsOfFile:path]];
        [[[[self navigationController] navigationBar] topItem] setTitle:AR_TEXT_TITLE_WELCOME];
    }
    else
    {
        [self setCurrentTypeContent:ARTypeContentImage];
        [self setCountResources: [[[self config] imagesAR] count]];
        [[self labelInfoMessage] setText: AR_TEXT_HELP_MENU_STEP_1];
        NSString *path = [[self config] pathARResource:@"minuta_mini.jpg"];
        [[self imageInfoReference] setImage: [[UIImage alloc] initWithContentsOfFile:path]];
        [[[[self navigationController] navigationBar] topItem] setTitle:AR_TEXT_TITLE_MENU];
    }
    
    NSLog(@"AugmentedView with type : %u", [self currentTypeContent]);
    
    [self setSdk:[CraftARSDK sharedCraftARSDK]];
    [[self sdk] setDelegate:self];
    
    [self setCloudRecognition: [CraftARCloudRecognition sharedCloudImageRecognition]];
    [[self cloudRecognition] setDelegate: self];
    
    [self setTracking: [CraftARTracking sharedTracking]];
    [[self tracking] setDelegate:self];
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    [[self sdk] startCaptureWithView:self.viewVideoPreview];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[self sdk]  stopCapture];
    [[self tracking]  removeAllARItems];
    [[ARApplicationController Instance] setContinueProccess:NO];
    [[ARApplicationController Instance] clearScenesOfType: [self currentTypeContent]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (IBAction)onTapBack:(UIButton *)sender
{
    if( [self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Backing...");
        }];
    }
}

#pragma mark -

#pragma mark Content Management

-(void) augmentedContent
{
    NSLog(@"menuAugmented.");
    
    if ([self countResources] > 1)
    {
        NSLog(@"Adding Controls");
        NSString *prevPath = [[NSBundle mainBundle] pathForResource:@"prev" ofType:@"png"];
        [self setPrevButton: [self makeButtonWithResource:[NSURL fileURLWithPath: prevPath]
                                                withScale: CATransform3DMakeScale(0.6, 0.6, 0.6)
                                           withTransition: CATransform3DMakeTranslation(-240, -261.33, 82.68)]];
        
        NSString *nextPath = [[NSBundle mainBundle] pathForResource:@"next" ofType:@"png"];
        [self setNextButton: [self makeButtonWithResource:[NSURL fileURLWithPath: nextPath]
                                                withScale: CATransform3DMakeScale(0.6, 0.6, 0.6)
                                           withTransition: CATransform3DMakeTranslation(240, -261.33, 82.68)]];
    }
    
    [self updateCurrentScene];
    
    switch ([self currentTypeContent]) {
        case ARTypeContentImage:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(),
            ^{
                if ([[ARApplicationController Instance] continueProccess])
                {
                   [[self labelInfoMessage] setText: AR_TEXT_HELP_MENU_STEP_2];
                   [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig * config) {
                       [[self viewInfoBackground] setBackgroundColor: [ARViewUtils colorFromHexString: [config colorRosa]]];
                   }];
                }
            });
            break;
        }
            
        default:
            break;
    }
}

-(void) showScanning
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        NSLog(@"showScanning");
        self.viewScanOverlay.hidden = false;
        //self.viewBack.hidden = true;
    });

}

-(void) showBackButton
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        NSLog(@"showBackButton");
        self.viewScanOverlay.hidden = true;
        self.viewBack.hidden = false;
    });
    
}

-(void) updateCurrentScene
{
    // Si cambia el contenido se borra el cart...
    [self removeCart];
    
    if ([self currentScene])
    {
        [[self currentItem] removeContent:[[self currentScene] content]];
        if (([self countResources] > 1))
        {
            [[self currentItem] removeContent:[self prevButton]];
        }
    }
    
    [self setCurrentScene: [[ARApplicationController Instance] getSceneAt: [self currentIndex] ofType: [self currentTypeContent]]];
    [[[self currentScene] content] setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
    [[[self currentScene] content] setScale:CATransform3DMakeScale(1.5, 2.2, 1.5)];
    [[self currentItem] addContent:[[self currentScene] content]];
    
    if (([self countResources] > 1))
    {
        [[self currentItem] addContent: [self prevButton]];
        [[self currentItem] addContent: [self nextButton]];
    }
}

-(CraftARTrackingContent*) makeButtonWithResource: (NSURL*) pathResource withScale: (CATransform3D) scale withTransition: (CATransform3D) transition
{
    CraftARTrackingContent* content = [[CraftARTrackingContentImage alloc] initWithImageFromURL: pathResource];
    [content setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
    [content setScale: scale];
    [content setTranslation: transition];
    
    return content;
}

-(void) removeCart
{
    if ([self cart])
    {
        [[self currentItem] removeContent: [self cart]];
        [self setIsVisibleCard: NO];
        [self setCart: nil];
    }
}

-(void) toggleCard
{
    if ([self isVisibleCard])
    {
        [self removeCart];
    }
    else
    {
        if ([self cart] == nil)
        {
            NSString *pathResource = [[self config] pathARResource: [NSString stringWithFormat:@"info%lu.png", [self currentIndex]+1]];
            CraftARTrackingContent* content = [[CraftARTrackingContentImage alloc] initWithImageFromURL: [NSURL fileURLWithPath:pathResource]];
            [content setWrapMode: CRAFTAR_TRACKING_WRAP_ASPECT_FIT];
            [content setTranslation: CATransform3DMakeTranslation(0.0, 0.0, 142.63)];
            [content setScale: CATransform3DMakeScale(1.6, 1.6, 1.6)];
            [self setCart:content];
        }
        
        [[self currentItem] addContent:[self cart]];
        [self setIsVisibleCard: YES];
    }
}

#pragma mark Finder mode AR implementation

- (void) didStartCapture {
    
    [self showScanning];
    [[self sdk] setSearchControllerDelegate:[[self cloudRecognition] mSearchController]];
    
    __block ARAugmentedViewController* mySelf = self;
    
    [[ARApplicationController Instance] getConfigOnSuccess:^(ARConfig * config) {
        [[[self cloudRecognition] mSearchController] setSearchPeriod: [[config delay] intValue]];
        [[self cloudRecognition] setCollectionWithToken: [config arCollection] onSuccess:^{
            
            NSLog(@"Ready to search!");
            [[CraftARSDK sharedCraftARSDK] startFinder];
            
        } andOnError:^(NSError *error) {
            NSLog(@"Error setting token: %@", error.localizedDescription);
            
            [mySelf showBackButton];
        }];
    }];
}


- (void) didGetSearchResults:(NSArray *)results {
    
    NSLog(@"didGetSearchResults");
    if ([results count] > 0) {
        [[self sdk] stopFinder];
        
        CraftARSearchResult *result = [results objectAtIndex:0];
        CraftARItem* item = result.item;
        
        if ([item isKindOfClass:[CraftARItemAR class]])
        {
            NSLog(@"isKindOfClass CraftARItemAR");
            [self setCurrentItem: (CraftARItemAR*)item];
            if (   ([[item name] isEqualToString: AR_COLLECTION_TYPE_MEMORANDUM] && [self currentTypeContent] == ARTypeContentImage)
                || ([[item name] isEqualToString: AR_COLLECTION_TYPE_WELCOME] && [self currentTypeContent] == ARTypeContentVideo))
            {
                [self showBackButton];
                
                [self augmentedContent];
            
                NSError *err = [[self tracking] addARItem: [self currentItem]];
                if (err) {
                    NSLog(@"Error adding AR item: %@", err.localizedDescription);
                }
                else
                {
                    [[self tracking] startTracking];
                }
            }
        }
    }
    
    if ([self currentScene] == nil)
    {
        [[self sdk] startFinder];
    }
}

- (void) didFailSearchWithError:(NSError *)error
{
    NSLog(@"Error calling CRS: %@", [error localizedDescription]);
}

#pragma mark Receive Tracking and contents events
- (void) didStartTrackingItem:(CraftARItemAR *)item
{
    NSLog(@"Start tracking: %@", item.name);
}

- (void) didStopTrackingItem:(CraftARItemAR *)item
{
    NSLog(@"Stop tracking: %@", item.name);
}

- (void) didGetTouchEvent:(CraftARContentTouchEvent)event forContent:(CraftARTrackingContent *)content
{
    switch (event)
    {
        case CRAFTAR_CONTENT_TOUCH_IN:
            NSLog(@"Touch in: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_OUT:
            NSLog(@"Touch out: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_UP:
            NSLog(@"Touch up: %@", content.uuid);
            break;
        case CRAFTAR_CONTENT_TOUCH_DOWN:
            NSLog(@"Touch down: %@", content.uuid);
            
            if ([content isEqual:[self prevButton]])//([[[self prevButton] uuid] isEqualToString: content.uuid]) // touch prev button
            {
                if ([self currentIndex] > 0)
                {
                    [self setCurrentIndex: [self currentIndex] - 1];
                }
                else
                {
                    [self setCurrentIndex: [self countResources] - 1];
                }
                
                [self updateCurrentScene];
            }
            else if ([content isEqual:[self nextButton]])//([[[self nextButton] uuid] isEqualToString: content.uuid]) // touch next button
            {
                unsigned long lastResource = [self countResources] - 1;
                if ([self currentIndex] >= lastResource)
                {
                    [self setCurrentIndex: 0];
                }
                else
                {
                    [self setCurrentIndex: [self currentIndex] + 1];
                }
                
                [self updateCurrentScene];
            }
            else
            {
                if ([self currentTypeContent] == ARTypeContentImage) // other contents
                {
                    [self toggleCard];
                }
                else
                {
                    [[self currentItem] removeContent: [[self currentScene] content]];
                    //[[self navigationController] popViewControllerAnimated:YES]; // Regresar a la pantalla anterior.
                }
            }
            
            break;
        default:
            break;
    }
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
