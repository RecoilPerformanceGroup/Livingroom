#import "Mask.h"
#import <ofxCocoaPlugins/OpenDMX.h>
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
    
    [self addPropF:@"triangleWhiteRight"];
    [self addPropF:@"triangleWhiteLeft"];
    
    [self addPropF:@"triangleWhiteR"];
    [self addPropF:@"triangleWhiteG"];
    [self addPropF:@"triangleWhiteB"];

    [self addPropF:@"triangleBlack"];
    
    [self addPropF:@"publys"];
    [self addPropF:@"trackinglys"];
    
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
    
    
    
    ofVec2f proj = [triangleRight convertToProjection:ofVec2f(0,1)];
    proj *= ofVec2f(1,1);
    triangleFloorCoordinate[0] = [[GetPlugin(Keystoner) getSurface:@"Floor" viewNumber:0 projectorNumber:0] convertFromProjection:proj];
    
    proj = [triangleRight convertToProjection:ofVec2f([[triangleRight aspect] floatValue],1)];
    triangleFloorCoordinate[1] = [[GetPlugin(Keystoner) getSurface:@"Floor" viewNumber:0 projectorNumber:0] convertFromProjection:proj];
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
            
            if(surface == triangleRight){
                ofVec2f proj = [surface convertToProjection:ofVec2f(0,1)];
                proj *= ofVec2f(1,1);
                triangleFloorCoordinate[0] = [[GetPlugin(Keystoner) getSurface:@"Floor" viewNumber:0 projectorNumber:0] convertFromProjection:proj];
                
                proj = [surface convertToProjection:ofVec2f([[surface aspect] floatValue],1)];
                triangleFloorCoordinate[1] = [[GetPlugin(Keystoner) getSurface:@"Floor" viewNumber:0 projectorNumber:0] convertFromProjection:proj];
            }
            adjustInProgress = NO;
        }
    }
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    OpenDMX * dmx = GetPlugin(OpenDMX);
    [dmx setValue:PropF(@"publys")*255.0 forChannel:5];
    [dmx setValue:PropF(@"publys")*255.0 forChannel:13];
    
    [dmx setValue:PropF(@"trackinglys")*255.0 forChannel:157];
    [dmx setValue:PropF(@"trackinglys")*255.0 forChannel:165];
    [dmx setValue:PropF(@"trackinglys")*255.0 forChannel:173];
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
    ofEnableAlphaBlending();
    ofFill();
    ofSetColor(0,0,0,255.0*PropF(@"rightBlind"));
    ofRect(0,0,0.5,1);
    
    ofSetColor(0,0,0,255.0*PropF(@"leftBlind"));
    ofRect(0.5,0,0.5,1);
    
    ApplySurface(@"Triangle"){
        float aspect = Aspect(@"Triangle",0);
        ofSetColor(0,0,0,255.0*PropF(@"triangleBlack"));
        ofTriangle(aspect, 0, aspect, 1, 0, 1);
        
        if(appliedProjector == 0){
            ofSetColor(PropF(@"triangleWhiteR")*255.0,PropF(@"triangleWhiteG")*255.0,PropF(@"triangleWhiteB")*255.0,255.0*PropF(@"triangleWhiteRight"));
        } else {
            ofSetColor(PropF(@"triangleWhiteR")*255.0,PropF(@"triangleWhiteG")*255.0,PropF(@"triangleWhiteB")*255.0,255.0*PropF(@"triangleWhiteLeft"));
        }
        ofTriangle(aspect, 0, aspect, 1, 0, 1);
    } PopSurface();
    
    if([[[GetPlugin(Keystoner) properties] valueForKey:@"Enabled"] boolValue]){
        ofSetColor(255,255,255);
        ApplySurface(@"Floor");
        ofCircle(triangleFloorCoordinate[0].x, triangleFloorCoordinate[0].y, 0.01);
        ofCircle(triangleFloorCoordinate[1].x, triangleFloorCoordinate[1].y, 0.01);
        PopSurface();
        
        ofSetColor(255,0,0);
        
        ApplySurface(@"Triangle");
        ofLine(0,1 , Aspect(@"Triangle", 0)*2,-1);
        PopSurface();
        
    }
    
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}

-(ofVec2f) triangleFloorCoordinate:(float)n{
    if(n == 0){
        return triangleFloorCoordinate[0];
    }
    if(n == 1){
        return triangleFloorCoordinate[1];
    }
    return ;
}
@end
