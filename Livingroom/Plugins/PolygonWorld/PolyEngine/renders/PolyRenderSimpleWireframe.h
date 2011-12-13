//
//  PolyRenderSimpleWireframe.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PolyRender.h"

@interface PolyRenderSimpleWireframe : PolyRender{
    int drawGridMode;
    int drawFillMode;    
}
@property (readwrite) int drawGridMode;
@property (readwrite) int drawFillMode;

@end
