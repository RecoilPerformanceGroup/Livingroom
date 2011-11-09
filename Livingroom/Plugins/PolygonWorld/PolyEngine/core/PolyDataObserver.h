//
//  PolyDataObserver.h
//  Livingroom
//
//  Created by ole kristensen on 09/11/11.
//  Copyright (c) 2011 Recoil Performance Group. All rights reserved.
//

#include "PolyInclude.h"

#ifndef Livingroom_PolyDataObserver_h
#define Livingroom_PolyDataObserver_h


// An observer to manage data in the arrangement, see
// http://www.cgal.org/Manual/3.3/doc_html/cgal_manual/Arrangement_2_ref/Class_Arr_observer.html

class PolyDataObserver : public CGAL::Arr_observer<Arrangement_2>
{
public:
    
    PolyDataObserver (Arrangement_2 *arr) :
    CGAL::Arr_observer<Arrangement_2> (*arr)
    {}
    
    virtual void before_split_face (Face_handle,
                                    Halfedge_handle e)
    {
        std::cout << "-> The insertion of :  [ " << e->curve()
        << " ]  causes a face to split." << std::endl;
    }
    
    virtual void before_merge_face (Face_handle,
                                    Face_handle,
                                    Halfedge_handle e)
    {
        std::cout << "-> The removal of :  [ " << e->curve()
        << " ]  causes two faces to merge." << std::endl;
    }
    
};

#endif
