#pragma once
#import <ofxCocoaPlugins/Plugin.h>


#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
//#include <OpenMesh/Core/IO/MeshIO.hh>
//#include <OpenMesh/Core/IO/Options.hh>
#include <OpenMesh/Core/Utils/GenProg.hh>
#include <OpenMesh/Core/Utils/color_cast.hh>
#include <OpenMesh/Core/Mesh/Attributes.hh>
#include <OpenMesh/Tools/Utils/StripifierT.hh>
#include <OpenMesh/Tools/Utils/Timer.hh>


typedef OpenMesh::TriMesh_ArrayKernelT<>   MyMesh;


@interface PolygonWorld : ofPlugin {
    MyMesh mesh;
    
    OpenMesh::FaceHandle face;

    int verticeIt;
    MyMesh::VertexHandle vhandle[500];
    
    ofVec2f p1,p2,p3;
    
}

@end
