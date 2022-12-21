
//  ZFOrentationObserver.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFOrientationObserver.h"
#import "ZFLandscapeWindow.h"
#import "ZFPortraitViewController.h"
#import "ZFPlayerConst.h"
#import <objc/runtime.h>

@interface UIWindow (CurrentViewController)

/*!
 @method currentViewController
 @return Returns the topViewController in stack of topMostController.
 */
+ (UIViewController*)zf_currentViewController;

@end

@implementation UIWindow (CurrentViewController)

+ (UIViewController*)zf_currentViewController; {
    __block UIWindow *window;
    if (@available(iOS 13, *)) {
        [[UIApplication sharedApplication].connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull scene, BOOL * _Nonnull scenesStop) {
            if ([scene isKindOfClass: [UIWindowScene class]]) {
                UIWindowScene * windowScene = (UIWindowScene *)scene;
                [windowScene.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull windowTemp, NSUInteger idx, BOOL * _Nonnull windowStop) {
                    if (windowTemp.isKeyWindow) {
                        window = windowTemp;
                        *windowStop = YES;
                        *scenesStop = YES;
                    }
                }];
            }
        }];
    } else {
        window = [[UIApplication sharedApplication].delegate window];
    }
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController *)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

@end

@interface ZFOrientationObserver () <ZFLandscapeViewControllerDelegate>

@property (nonatomic, weak) ZFPlayerView *view;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, strong) UIView *cell;

@property (nonatomic, assign) NSInteger playerViewTag;

@property (nonatomic, assign) ZFRotateType rotateType;

@property (nonatomic, strong) UIWindow *previousKeyWindow;

@property (nonatomic, strong) ZFLandscapeWindow *window;

@property (nonatomic, readonly, getter=isRotating) BOOL rotating;

@property (nonatomic, strong) ZFPortraitViewController *portraitViewController;

/// current device orientation observer is activie.
@property (nonatomic, assign) BOOL activeDeviceObserver;

/// Force Rotaion, default NO.
@property (nonatomic, assign) BOOL forceRotaion;

@end

@implementation ZFOrientationObserver
@synthesize presentationSize = _presentationSize;

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 0.30;
        _fullScreenMode = ZFFullScreenModeLandscape;
        _supportInterfaceOrientation = ZFInterfaceOrientationMaskAllButUpsideDown;
        _allowOrientationRotation = YES;
        _rotateType = ZFRotateTypeNormal;
        _currentOrientation = UIInterfaceOrientationPortrait;
        _portraitFullScreenMode = ZFPortraitFullScreenModeScaleToFill;
        _disablePortraitGestureTypes = ZFDisablePortraitGestureTypesAll;
    }
    return self;
}

- (void)updateRotateView:(ZFPlayerView *)rotateView
           containerView:(UIView *)containerView {
    self.rotateType = ZFRotateTypeNormal;
    self.view = rotateView;
    self.containerView = containerView;
}

- (void)updateRotateView:(ZFPlayerView *)rotateView rotateViewAtCell:(UIView *)cell playerViewTag:(NSInteger)playerViewTag {
    self.rotateType = ZFRotateTypeCell;
    self.view = rotateView;
    self.cell = cell;
    self.playerViewTag = playerViewTag;
}

- (void)dealloc {
    [self removeDeviceOrientationObserver];
}

- (void)addDeviceOrientationObserver {
    if (self.allowOrientationRotation) {
        self.activeDeviceObserver = YES;
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)removeDeviceOrientationObserver {
    self.activeDeviceObserver = NO;
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange {
    if (self.fullScreenMode == ZFFullScreenModePortrait || !self.allowOrientationRotation) return;
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;

    // Determine that if the current direction is the same as the direction you want to rotate, do nothing
    if (currentOrientation == _currentOrientation) return;
    _currentOrientation = currentOrientation;
    if (_currentOrientation == UIInterfaceOrientationPortraitUpsideDown) return;
    
    switch (currentOrientation) {
        case UIInterfaceOrientationPortrait: {
            if ([self _isSupportedPortrait]) {
                [self rotateToOrientation:UIInterfaceOrientationPortrait animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if ([self _isSupportedLandscapeLeft]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if ([self _isSupportedLandscapeRight]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - public

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self rotateToOrientation:orientation animated:animated completion:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion {
    if (self.fullScreenMode == ZFFullScreenModePortrait) return;
    _currentOrientation = orientation;
    self.forceRotaion = YES;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (!self.fullScreen) {
            UIView *containerView = nil;
            if (self.rotateType == ZFRotateTypeCell) {
                containerView = [self.cell viewWithTag:self.playerViewTag];
            } else {
                containerView = self.containerView;
            }
            CGRect targetRect = [self.view convertRect:self.view.frame toView:containerView.window];
            
            if (!self.window) {
                self.window = [ZFLandscapeWindow new];
                self.window.landscapeViewController.delegate = self;
                if (@available(iOS 9.0, *)) {
                    [self.window.rootViewController loadViewIfNeeded];
                } else {
                    [self.window.rootViewController view];
                }
            }
            
            self.window.landscapeViewController.targetRect = targetRect;
            self.window.landscapeViewController.contentView = self.view;
            self.window.landscapeViewController.containerView = self.containerView;
            self.fullScreen = YES;
        }
        if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
    } else {
        self.fullScreen = NO;
    }
    self.window.landscapeViewController.disableAnimations = !animated;
    @zf_weakify(self)
    self.window.landscapeViewController.rotatingCompleted = ^{
        @zf_strongify(self)
        self.forceRotaion = NO;
        if (completion) completion();
    };
    
    [self interfaceOrientation:UIInterfaceOrientationUnknown];
    [self interfaceOrientation:orientation];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    [self enterPortraitFullScreen:fullScreen animated:animated completion:nil];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void(^ __nullable)(void))completion {
    self.fullScreen = fullScreen;
    if (fullScreen) {
        self.portraitViewController.contentView = self.view;
        self.portraitViewController.containerView = self.containerView;
        self.portraitViewController.duration = self.duration;
        if (self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleAspectFit) {
            self.portraitViewController.presentationSize = self.presentationSize;
        } else if (self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleToFill) {
            self.portraitViewController.presentationSize = CGSizeMake(ZFPlayerScreenWidth, ZFPlayerScreenHeight);
        }
        self.portraitViewController.fullScreenAnimation = animated;
        [[UIWindow zf_currentViewController] presentViewController:self.portraitViewController animated:animated completion:^{
            if (completion) completion();
        }];
    } else {
        self.portraitViewController.fullScreenAnimation = animated;
        [self.portraitViewController dismissViewControllerAnimated:animated completion:^{
            if (completion) completion();
        }];
    }
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    [self enterFullScreen:fullScreen animated:animated];
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        [self enterPortraitFullScreen:fullScreen animated:animated completion:completion];
    } else {
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        orientation = fullScreen? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        [self rotateToOrientation:orientation animated:animated completion:completion];
    }
}

#pragma mark - private

/// is support portrait
- (BOOL)_isSupportedPortrait {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait;
}

/// is support landscapeLeft
- (BOOL)_isSupportedLandscapeLeft {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeLeft;
}

/// is support landscapeRight
- (BOOL)_isSupportedLandscapeRight {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)_isSupported:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait;
        case UIInterfaceOrientationLandscapeLeft:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeRight;
        default:
            return NO;
    }
    return NO;
}

- (void)_rotationToLandscapeOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        if (keyWindow != self.window && self.previousKeyWindow != keyWindow) {
            self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
        }
        if (!self.window.isKeyWindow) {
            self.window.hidden = NO;
            [self.window makeKeyAndVisible];
        }
    }
}

- (void)_rotationToPortraitOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait && !self.window.hidden) {
        UIView *containerView = nil;
        if (self.rotateType == ZFRotateTypeCell) {
            containerView = [self.cell viewWithTag:self.playerViewTag];
        } else {
            containerView = self.containerView;
        }
        UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:NO];
        snapshot.frame = containerView.bounds;
        [containerView addSubview:snapshot];
        [self performSelector:@selector(_contentViewAdd:) onThread:NSThread.mainThread withObject:containerView waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        [self performSelector:@selector(_makeKeyAndVisible:) onThread:NSThread.mainThread withObject:snapshot waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    }
}

- (void)_contentViewAdd:(UIView *)containerView {
    [containerView addSubview:self.view];
    self.view.frame = containerView.bounds;
    [self.view layoutIfNeeded];
}

- (void)_makeKeyAndVisible:(UIView *)snapshot {
    [snapshot removeFromSuperview];
    UIWindow *previousKeyWindow = self.previousKeyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    [previousKeyWindow makeKeyAndVisible];
    self.previousKeyWindow = nil;
    self.window.hidden = YES;
}

#pragma mark - ZFLandscapeViewControllerDelegate

- (BOOL)ls_shouldAutorotate {
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        return NO;
    }
    
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (![self _isSupported:currentOrientation]) {
        return NO;
    }
    
    if (self.forceRotaion) {
        [self _rotationToLandscapeOrientation:currentOrientation];
        return YES;
    }
    
    if (!self.activeDeviceObserver) {
        return NO;
    }
    
    [self _rotationToLandscapeOrientation:currentOrientation];
    return YES;
}

- (void)ls_willRotateToOrientation:(UIInterfaceOrientation)orientation {
    self.fullScreen = UIInterfaceOrientationIsLandscape(orientation);
    if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
}

- (void)ls_didRotateFromOrientation:(UIInterfaceOrientation)orientation {
    if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
    if (!self.isFullScreen) {
        [self _rotationToPortraitOrientation:UIInterfaceOrientationPortrait];
    }
}

- (CGRect)ls_targetRect {
    UIView *containerView = nil;
    if (self.rotateType == ZFRotateTypeCell) {
        containerView = [self.cell viewWithTag:self.playerViewTag];
    } else {
        containerView = self.containerView;
    }
    CGRect targetRect = [containerView convertRect:containerView.bounds toView:containerView.window];
    return targetRect;
}

#pragma mark - getter

- (ZFPortraitViewController *)portraitViewController {
    if (!_portraitViewController) {
        @zf_weakify(self)
        _portraitViewController = [[ZFPortraitViewController alloc] init];
        if (@available(iOS 9.0, *)) {
            [_portraitViewController loadViewIfNeeded];
        } else {
            [_portraitViewController view];
        }
        _portraitViewController.orientationWillChange = ^(BOOL isFullScreen) {
            @zf_strongify(self)
            self.fullScreen = isFullScreen;
            if (self.orientationWillChange) self.orientationWillChange(self, isFullScreen);
        };
        _portraitViewController.orientationDidChanged = ^(BOOL isFullScreen) {
            @zf_strongify(self)
            self.fullScreen = isFullScreen;
            if (self.orientationDidChanged) self.orientationDidChanged(self, isFullScreen);
        };
    }
    return _portraitViewController;
}

#pragma mark - setter

- (void)setLockedScreen:(BOOL)lockedScreen {
    _lockedScreen = lockedScreen;
    if (lockedScreen) {
        [self removeDeviceOrientationObserver];
    } else {
        [self addDeviceOrientationObserver];
    }
}

- (UIView *)fullScreenContainerView {
    if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        return self.window.landscapeViewController.view;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        return self.portraitViewController.view;
    }
    return nil;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)setFullScreenStatusBarHidden:(BOOL)fullScreenStatusBarHidden {
    _fullScreenStatusBarHidden = fullScreenStatusBarHidden;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarHidden = fullScreenStatusBarHidden;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarHidden = fullScreenStatusBarHidden;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setFullScreenStatusBarStyle:(UIStatusBarStyle)fullScreenStatusBarStyle {
    _fullScreenStatusBarStyle = fullScreenStatusBarStyle;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarStyle = fullScreenStatusBarStyle;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarStyle = fullScreenStatusBarStyle;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setFullScreenStatusBarAnimation:(UIStatusBarAnimation)fullScreenStatusBarAnimation {
    _fullScreenStatusBarAnimation = fullScreenStatusBarAnimation;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarAnimation = fullScreenStatusBarAnimation;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarAnimation = fullScreenStatusBarAnimation;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setDisablePortraitGestureTypes:(ZFDisablePortraitGestureTypes)disablePortraitGestureTypes {
    _disablePortraitGestureTypes = disablePortraitGestureTypes;
    self.portraitViewController.disablePortraitGestureTypes = disablePortraitGestureTypes;
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if (self.fullScreenMode == ZFFullScreenModePortrait && self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleAspectFit) {
        self.portraitViewController.presentationSize = presentationSize;
    }
}

- (void)setView:(ZFPlayerView *)view {
    if (view == _view) {
        return;
    }
    _view = view;
    if (self.fullScreenMode == ZFFullScreenModeLandscape && self.window) {
        self.window.landscapeViewController.contentView = view;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.contentView = view;
    }
}

- (void)setContainerView:(UIView *)containerView {
    if (containerView == _containerView) {
        return;
    }
    _containerView = containerView;
    if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.containerView = containerView;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.containerView = containerView;
    }
}

- (void)setAllowOrientationRotation:(BOOL)allowOrientationRotation {
    _allowOrientationRotation = allowOrientationRotation;
    if (allowOrientationRotation) {
        [self addDeviceOrientationObserver];
    } else {
        [self removeDeviceOrientationObserver];
    }
}

@end
