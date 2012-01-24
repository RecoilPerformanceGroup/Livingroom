#import "Mask.h"

@implementation Mask

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)initPlugin{
    [self addPropF:@"leftBlind"];
    [self addPropF:@"rightBlind"];
}

//
//----------------
//


-(void)setup{
    Keystoner * keystoner = GetPlugin(Keystoner);
    triangleRight = [keystoner getSurface:@"Triangle" viewNumber:0 projectorNumber:0];
    triangleLeft = [keystoner getSurface:@"Triangle" viewNumber:0 projectorNumber:1];
    
    for(int i=0;i<4;i++){
        [[[triangleRight cornerPositions] objectAtIndex:i] addObserver:self forKeyPath:@"x" options:nil context:triangleRight];
        [[[triangleRight cornerPositions] objectAtIndex:i] addObserver:self forKeyPath:@"y" options:nil context:triangleRight];
        [[[triangleLeft cornerPositions] objectAtIndex:i] addObserver:self forKeyPath:@"x" options:nil context:triangleLeft];
        [[[triangleLeft cornerPositions] objectAtIndex:i] addObserver:self forKeyPath:@"y" options:nil context:triangleLeft];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if(!adjustInProgress){
        if([keyPath isEqualToString:@"x"] || [keyPath isEqualToString:@"y"] ){
            adjustInProgress = TRUE;
            KeystoneSurface * surface = (KeystoneSurface*)context;
            
            ofVec2f corners[4];
            for(int i=0;i<4;i++){
                corners[i] = ofVec2f([[[[surface cornerPositions] objectAtIndex:i] valueForKey:@"x"] floatValue],
                                     [[[[surface cornerPositions] objectAtIndex:i] valueForKey:@"y"] floatValue]);
            }
            
            ofVec2f v1 = corners[1] - corners[2];
            ofVec2f v2 = corners[3] - corners[2];
            
            
            ofVec2f goal = corners[2] + v1 + v2;
            
            
            if(corners[0] != goal){
                
                NSDictionary * ps = [[surface cornerPositions] objectAtIndex:0];
                [ps setValue:[NSNumber numberWithFloat:goal.x] forKey:@"x"];
                [ps setValue:[NSNumber numberWithFloat:goal.y] forKey:@"y"];
            }
            [surface recalculate];
            adjustInProgress = NO;
        }
    }
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    
    ofSetColor(0,0,0,255.0*PropF(@"rightBlind"));
    ofRect(0,0,0.5,1);
    
    ofSetColor(0,0,0,255.0*PropF(@"leftBlind"));
    ofRect(0.5,0,0.5,1);
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

@end
