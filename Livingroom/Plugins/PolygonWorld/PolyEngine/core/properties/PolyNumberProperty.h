#import "lrAppDelegate.h"
#import <Foundation/Foundation.h>

@interface PolyNumberProperty : NumberProperty{
    NSMutableArray * sceneTokens;
    int sortNumber;
}

@property (readwrite, retain) NSMutableArray * sceneTokens;
@property (readwrite) int sortNumber;
@end
