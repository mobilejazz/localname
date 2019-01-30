#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GoogleAnalyticsTracker.h"
#import "MPAnalyticsConfiguration.h"
#import "MPAnalyticsDebugWindowController.h"
#import "MPAnalyticsParamBuilder.h"
#import "MPGoogleAnalyticsTracker.h"

FOUNDATION_EXPORT double GoogleAnalyticsTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char GoogleAnalyticsTrackerVersionString[];

