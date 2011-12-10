//
//  CGALEnumerator.m
//  Livingroom
//
//  Created by Livingroom on 09/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CGALEnumerator.h"

@implementation CGALEnumerator

+(CGALEnumerator*) vertexFromArr:(Arrangement_2*)arr{
    static CGALEnumerator * prop = nil;
	prop = [[CGALEnumerator alloc] init];
    
    cout<<"size "<<sizeof(Arrangement_2::Vertex_iterator)<<endl;
	
	return prop;
}

//------
/*

typedef union
{
    unsigned long extra[5];
    struct
    {
        NSInteger stride;
        NSInteger current;
        BOOL done;
    } state;
} DDRangeExtra;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackBuf
                                    count:(NSUInteger)len
{
    DDRangeExtra * extra = (DDRangeExtra *) &state->extra;
    if (state->state == 0)
    {
        // All zeros means an empty range
        if ((_to == 0) && (_from == 0) && (_stride == 0))
            return 0;
        
        state->state = 1;
        state->mutationsPtr = (unsigned long *) self;
        if (_from < _to)
            extra->state.stride = 1 * _stride;
        else
            extra->state.stride = -1 * _stride;
        extra->state.done = NO;
        extra->state.current = _from;
        state->itemsPtr = stackBuf;
    }
    
    id * currentItem = &state->itemsPtr[0];
    NSUInteger returned = 0;
    while ((len > 0) && !extra->state.done)
    {
        if ((extra->state.stride > 0) && (extra->state.current > _to))
        {
            extra->state.done = YES;
            break;
        }
        if ((extra->state.stride < 0) && (extra->state.current < _to))
        {
            extra->state.done = YES;
            break;
        }
        
        *currentItem = (id) extra->state.current;
        returned++;
        len--;
        extra->state.current += extra->state.stride;
        currentItem++;
    }
    return returned;
}*/
@end
