//
//  PolyRenderCracks.m
//  Livingroom
//
//  Created by ole kristensen on 10/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#import "PolyRenderCrackLines.h"
#import <ofxCocoaPlugins/CustomGraphics.h>

@implementation PolyRenderCrackLines

- (id)init {
    self = [super init];
    if (self) {
        [self addPropF:@"lineWidth"];
        [self addPropF:@"lineWidthMax"];
        
        [self addPropF:@"cloudIntensity"];
        [self addPropF:@"cloudSize"];
        
    }
    return self;
}

-(void)setup{
    NSBundle *framework=[NSBundle bundleForClass:[self class]];
    NSString * path = [framework pathForResource:@"Gradient" ofType:@"png"];
    gradient = new ofImage();
    bool imageLoaded = false;
    if(path != nil)
        imageLoaded = gradient->loadImage([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!imageLoaded){
        NSLog(@"gradients image not found in cracks!!");
    }
    
    for(int i=0;i<NUM_GRADIENTS;i++){
        gradients[i].x = ofRandom(0,1); //X
        gradients[i].y = ofRandom(0,1); //Y
        gradients[i].size = ofRandom(0.1, 0.2); //Size 
        gradients[i].intensity = ofRandom(0.1,0.5); //Intensity range
        gradients[i].val = 0; //Intensity
    }
    
    
    
}

-(void)draw:(NSDictionary *)drawingInformation{
    //    ApplySurfaceForProjector(@"Floor",0);{
    
    ofEnableAlphaBlending();
    
    
    //Gradients
    {
        CachePropF(cloudSize);
        CachePropF(cloudIntensity);
        
        [[engine arrangement] enumerateVertices:^(Arrangement_2::Vertex_iterator vit) {
            if(vit->data().crackAmount > 0){
                for(int i=0;i<NUM_GRADIENTS;i++){
                    if(handleToVec2(vit).distance(ofVec2f(gradients[i].x, gradients[i].y)) < gradients[i].size){
                        gradients[i].val += 0.001;
                        if(gradients[i].val > 1)
                            gradients[i].val = 1;
                    }
                }
            }
        }];
        
        gradient->bind();
        glBegin(GL_QUADS);
        for(int i=0;i<NUM_GRADIENTS;i++){
            if(gradients[i].val > 0){
                float a = 255.0*gradients[i].intensity * cloudIntensity * gradients[i].val;
                ofSetColor(255,255,255,a);
                float size = gradients[i].size*cloudSize;
                glTexCoord2f(0, 0);                                 glVertex2d(gradients[i].x-size, gradients[i].y-size);
                glTexCoord2f(gradient->width, 0);                   glVertex2d(gradients[i].x+size, gradients[i].y-size);
                glTexCoord2f(gradient->width, gradient->height);    glVertex2d(gradients[i].x+size, gradients[i].y+size);
                glTexCoord2f(0, gradient->height);                   glVertex2d(gradients[i].x-size, gradients[i].y+size);
                
                //gradient->draw(gradients[i].x-gradients[i].size*cloudSize,gradients[i].y-gradients[i].size*cloudSize, gradients[i].size*2*cloudSize, gradients[i].size*2*cloudSize);
            }
        }
        glEnd();
        gradient->unbind();
    }
    
    ofSetColor(255,255,255,255);
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    
    
    Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
    
    ofSetColor(0,0,0,255.0);
    float lineWidth = PropF(@"lineWidth");
    float lineWidthMax = PropF(@"lineWidthMax");
    
    glBegin(GL_QUADS);
    for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
        float crack = eit->data().crackAmount + eit->twin()->data().crackAmount;
        // ofSetColor(255.0*crack,255.0*(1-crack),0,255);
        // ofSetColor(0*crack,0,0,255.0*crack);
        
        // ofSetLineWidth(eit->data().crackAmount*2.0);
        
        
        /*        ofLine(handleToVec2(h1).x, handleToVec2(h1).y, handleToVec2(h2).x, handleToVec2(h2).y);*/
        
        if(crack > 0){
            
            Arrangement_2::Vertex_handle h1 = eit->source();
            Arrangement_2::Vertex_handle h2 = eit->target();
            
            float sourceAmm = h1->data().crackAmount;
            float destAmm = h2->data().crackAmount;
            
            int sourceCount = h1->data().crackEdgeCount;
            int destCount = h2->data().crackEdgeCount;
            
            ofVec2f hat = calculateEdgeNormal(eit).normalized();
            
            float width = sourceAmm;
            if(sourceCount < 2)
                width = 0;
            if(width > lineWidthMax)
                width = lineWidthMax;
            
            glVertex2d(handleToVec2(h1).x - hat.x*0.01*lineWidth*width, handleToVec2(h1).y - hat.y*0.01*lineWidth*width);
            glVertex2d(handleToVec2(h1).x + hat.x*0.01*lineWidth*width, handleToVec2(h1).y + hat.y*0.01*lineWidth*width);
            
            width = destAmm;
            if(destCount < 2)
                width = 0;
            if(width > lineWidthMax)
                width = lineWidthMax;
            
            glVertex2d(handleToVec2(h2).x + hat.x*0.01*lineWidth*width, handleToVec2(h2).y + hat.y*0.01*lineWidth*width);                       
            glVertex2d(handleToVec2(h2).x - hat.x*0.01*lineWidth*width, handleToVec2(h2).y - hat.y*0.01*lineWidth*width);
            
        }
        
        /*   ofVec2f dir = handleToVec2(h2) - handleToVec2(h1);
         dir.normalize();
         ofVec2f hat = ofVec2f(-dir.y, dir.x)*0.008;
         
         dir *= 0.02;
         
         of2DArrow(handleToVec2(eit->source())-hat+dir, handleToVec2(eit->target())-hat-dir, 0.015);
         
         crack = eit->twin()->data().crackAmount;
         ofSetColor(255.0*crack,255.0*(1-crack),0,255);
         
         
         of2DArrow(handleToVec2(eit->target())+hat-dir, handleToVec2(eit->source())+hat+dir, 0.015);*/
        
    }      
    glEnd();
    
    // }PopSurfaceForProjector();
    
}

-(void)controlDraw:(NSDictionary *)drawingInformation{
    
    Arrangement_2::Edge_iterator eit = [[engine arrangement] arrData]->edges_begin();    
    
    ofSetColor(255,255,255,128);
    
    glPolygonMode(GL_FRONT_AND_BACK , GL_FILL);
    
    for ( ; eit !=[[engine arrangement] arrData]->edges_end(); ++eit) {
        
        ofCircle(CGAL::to_double(eit->source()->point().x()) , CGAL::to_double(eit->source()->point().y()), eit->data().crackAmount*0.05);
        
    }   
    
}

@end
