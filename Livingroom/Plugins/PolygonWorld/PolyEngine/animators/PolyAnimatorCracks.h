//
//  PolyAnimatorCracks.h
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyAnimator.h"

@interface PolyAnimatorCracks : PolyAnimator{

    BOOL mousePressed;
    ofVec2f mouse;
    vector< vector<ofVec2f> > crackLines;
    vector< Arrangement_2::Vertex_handle > crackLinesVertices;
    
    int impulse;
    int invimpulse;
}
@property (readonly)     vector< vector<ofVec2f> > crackLines;
@end
