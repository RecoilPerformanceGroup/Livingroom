#import "OSCControl.h"

@implementation OSCControl

- (id)init{
    self = [super init];
    if (self) {
        sender = new ofxOscSender();
        receiver = new ofxOscReceiver();
        
        //        sender->setup("Ecotelemedia-iPad-Mobile-6.local", 8080);
        sender->setup("10.0.2.2", 8080);
        receiver->setup(9090);
    }
    
    return self;
}

//
//----------------
//



-(void) createInterface {
    {    
        ofxOscMessage m;
        m.setAddress( "/control/createBlankInterface" );    
        m.addStringArg( "ofxCocoaPlugins" );
        m.addStringArg( "landscape" );
        sender->sendMessage( m );
    }
    {    
        ofxOscMessage m;
        m.setAddress( "/control/pushDestination" );    
        m.addStringArg( "recoil.local:9090" );
        sender->sendMessage( m );
    }
}


- (string)dictToJson:(NSDictionary*) dict{
    string s = "{";
    for(NSString * key in dict){
        s.append("'");
        s.append([key cStringUsingEncoding:NSUTF8StringEncoding]);
        s.append("':");
        
        id value = [dict valueForKey:key];
        if([value isKindOfClass:[NSString class]]){
            if([key isEqualToString:@"bounds"]){
                s.append([value cStringUsingEncoding:NSUTF8StringEncoding]);                
            } else {
                s.append("'");
                s.append([value cStringUsingEncoding:NSUTF8StringEncoding]);
                s.append("'");
            }
        } else if([value isKindOfClass:[NSNumber class]]){
            s.append([[NSString stringWithFormat:@"%@", value] cStringUsingEncoding:NSUTF8StringEncoding]);            
        }
        s.append(", ");
    }
    s.append("}");
    return s;
}

- (NSString*) rectToBoundsString:(NSRect)rect{
    return [NSString stringWithFormat:@"[%f,%f,%f,%f]", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (void)addWidget:(NSDictionary*)json{
    string s = [self dictToJson:json];
    cout<<s<<endl;
    
    ofxOscMessage m;
    m.setAddress( "/control/addWidget" );    
    m.addStringArg( s );
    sender->sendMessage( m );
    
}

//mode: There are 5 different possible modes for buttons. The default value is toggle.
//  toggle: Alternates between the buttons min and max values on each press

//  momentary: Outputs max when button is pressed, min when button is released 
//      or when touch travels outside button     boundaries

//  latch: Outputs max when button is pressed, min when button is released. 
//      As opposed to momentary, this does not release when the touch travels 
//      outside the button boundaries, only when the touch that initially triggered the button ends

//  contact: The button only outputs the max value, and only when it is first pressed.

//  visualToggle: The button always outputs max but toggles on and off visually (useful in some MIDI circumstances)

- (void) addButton:(NSString*)name label:(NSString*)label labelSize:(int)labelSize bounds:(NSRect)bounds mode:(NSString*)mode{
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     name, @"name",
                     @"Button",@"type",
                     [NSNumber numberWithFloat:bounds.origin.x], @"x",
                     [NSNumber numberWithFloat:bounds.origin.y], @"y",
                     [NSNumber numberWithFloat:bounds.size.width], @"width",
                     [NSNumber numberWithFloat:bounds.size.height], @"height",
                     [NSString stringWithFormat:@"%i",labelSize], @"labelSize",
                     label, @"label",
                     mode, @"mode",
                     nil]];
}

- (void) addMultiXY:(NSString*)name bounds:(NSRect)bounds isMomentary:(BOOL)isMomentary maxTouches:(int)maxTouches{
    [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
                     name, @"name",
                     @"MultiTouchXY",@"type",
                     [self rectToBoundsString:bounds], @"bounds",
                     [NSNumber numberWithBool:isMomentary], @"isMomentary",
                     [NSNumber numberWithBool:true], @"sendZValue",
                     [NSNumber numberWithInt:maxTouches], @"maxTouches",
                     nil]];
}

- (void) setColor:(NSString*)widget background:(NSString*)background foreground:(NSString*)foreground stroke:(NSString*)stroke {
    
    ofxOscMessage m;
    m.setAddress( "/control/setColors" );    
    m.addStringArg( [widget cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [background cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [foreground cStringUsingEncoding:NSUTF8StringEncoding] );
    m.addStringArg( [stroke cStringUsingEncoding:NSUTF8StringEncoding] );
    sender->sendMessage( m );
    
}



-(void)setup{
    [self createInterface];
    
    
    /*  [self addWidget:[NSDictionary dictionaryWithObjectsAndKeys:
     @"test2", @"name",
     @"Slider",@"type",
     @"[.0,.4,.75,.3]",@"bounds", 
     nil]];
     */
    
    [self addMultiXY:@"trackerxy" bounds:NSMakeRect(0.0, 0.0, 0.75, 1.0) isMomentary:true maxTouches:3];
    [self setColor:@"trackerxy" background:@"#000" foreground:@"#aaa" stroke:@"#ddd"];
    
    [self addButton:@"but1" label:@"Buttons" labelSize:10 bounds:NSMakeRect(0.8, 0.0, 0.2, 0.1) mode:@"contact"];
}

//
//----------------
//


-(void)update:(NSDictionary *)drawingInformation{
    while( receiver->hasWaitingMessages() )
	{
		// get the next message
		ofxOscMessage m;
		receiver->getNextMessage( &m );
        //cout<<"OSC: "<<m.getAddress()<<"  "<<m.getNumArgs()<<endl;
        
        for(int i=0;i<10;i++){
            if(m.getAddress() == "/trackerxy/"+ofToString(i)){
                trackerData[i].point.x = m.getArgAsFloat(0);
                trackerData[i].point.y = m.getArgAsFloat(1);
                trackerData[i].active = m.getArgAsFloat(2);
                
            }
        }
        
    }
}

//
//----------------
//

-(void)draw:(NSDictionary *)drawingInformation{
}

//
//----------------
//

-(void)controlDraw:(NSDictionary *)drawingInformation{    
}



- (oscTrackerData) getTracker:(int)tracker{
    if(tracker >= 0 && tracker < 10){
        return trackerData[tracker];
    }
    return oscTrackerData();
}

- (vector<ofVec2f>) getTrackerCoordinates{
    vector<ofVec2f> v;
    for(int i=0;i<10;i++){
        if(trackerData[i].active){
            v.push_back(trackerData[i].point);
        }
    }
    return v;
}




@end


