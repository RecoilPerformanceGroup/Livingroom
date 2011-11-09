//
//  PolyArrangement.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "lrAppDelegate.h"

#import <Foundation/Foundation.h>

@interface PolyArrangement : NSObject{
    Arrangement_2 * arr;
}

@property (readonly) Arrangement_2 * arr;

-(Point_2) n_point;

-(vector< Polygon_2 >) hulls;
@end
