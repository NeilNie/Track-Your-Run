//
//  MainViewController.m
//  Done!
//
//  Created by Yongyang Nie on 6/6/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "MainViewController.h"
#import "LeftViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) LeftViewController *leftViewController;
@property (assign, nonatomic) NSUInteger type;

@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.leftViewBackgroundColor = [UIColor whiteColor];
}

- (void)setupWithPresentationStyle:(LGSideMenuPresentationStyle)style
                              type:(NSUInteger)type
{
    _leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    
    // -----
    if (type == 0)
    {
        [self setLeftViewEnabledWithWidth:250.f
                        presentationStyle:style
                     alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnNone];
        
        self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnNone;
        
        // -----
        
        if (style == LGSideMenuPresentationStyleScaleFromBig)
        {
            self.leftViewBackgroundImage = [UIImage imageNamed:@"image"];
            
            _leftViewController.tableView.backgroundColor = [UIColor clearColor];
            _leftViewController.tintColor = [UIColor whiteColor];
            
        }
        else if (style == LGSideMenuPresentationStyleSlideAbove)
        {
            self.leftViewBackgroundColor = [UIColor colorWithWhite:1.f alpha:0.9];
            
            _leftViewController.tableView.backgroundColor = [UIColor clearColor];
            _leftViewController.tintColor = [UIColor whiteColor];

        }
        else if (style == LGSideMenuPresentationStyleSlideBelow)
        {
            self.leftViewBackgroundImage = [UIImage imageNamed:@"image"];
            
            _leftViewController.tableView.backgroundColor = [UIColor clearColor];
            _leftViewController.tintColor = [UIColor whiteColor];

        }
        else if (style == LGSideMenuPresentationStyleScaleFromLittle)
        {
            self.leftViewBackgroundImage = [UIImage imageNamed:@"image"];
            
            _leftViewController.tableView.backgroundColor = [UIColor clearColor];
            _leftViewController.tintColor = [UIColor whiteColor];
            
        }
    }
    else if (type == 1)
    {
        [self setLeftViewEnabledWithWidth:250.f
                        presentationStyle:style
                     alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnPhoneLandscape|LGSideMenuAlwaysVisibleOnPadLandscape];
        
        self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
        self.leftViewStatusBarVisibleOptions = LGSideMenuAlwaysVisibleOnPadLandscape;
        self.leftViewBackgroundImage = [UIImage imageNamed:@"image"];
        
        _leftViewController.tableView.backgroundColor = [UIColor clearColor];
        _leftViewController.tintColor = [UIColor whiteColor];
        
    }
    else if (type == 2)
    {
        [self setLeftViewEnabledWithWidth:250.f
                        presentationStyle:style
                     alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnNone];
        
        self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnAll;
        self.leftViewBackgroundColor = [UIColor colorWithWhite:1.f alpha:0.9];
        
        _leftViewController.tableView.backgroundColor = [UIColor clearColor];
        _leftViewController.tintColor = [UIColor whiteColor];

    }
    else if (type == 3)
    {
        [self setLeftViewEnabledWithWidth:250.f
                        presentationStyle:style
                     alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnNone];
        
        self.leftViewStatusBarStyle = UIStatusBarStyleLightContent;
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnAll;
        self.leftViewBackgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        
        _leftViewController.tableView.backgroundColor = [UIColor clearColor];
        _leftViewController.tintColor = [UIColor whiteColor];

    }
    else if (type == 4)
    {        
        [self setLeftViewEnabledWithWidth:250.f
                        presentationStyle:LGSideMenuPresentationStyleScaleFromBig
                     alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnNone];
        
        self.leftViewAnimationSpeed = 0.4;
        self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnNone;
        self.leftViewBackgroundImage = [UIImage imageNamed:@"image"];
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnPadLandscape;
        self.leftViewBackgroundImageInitialScale = 1.5;
        self.leftViewInititialOffsetX = -200.f;
        self.leftViewInititialScale = 1.5;
        
        _leftViewController.tableView.backgroundColor = [UIColor clearColor];
        _leftViewController.tintColor = [UIColor whiteColor];

    }
    
    // -----
    
    [_leftViewController.tableView reloadData];
    [self.leftView addSubview:_leftViewController.tableView];

}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size
{
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    if (![UIApplication sharedApplication].isStatusBarHidden && (_type == 2 || _type == 3))
        _leftViewController.tableView.frame = CGRectMake(0.f , 20.f, size.width, size.height-20.f);
    else
        _leftViewController.tableView.frame = CGRectMake(0.f , 0.f, size.width, size.height);
}

@end;
