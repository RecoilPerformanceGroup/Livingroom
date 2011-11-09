//
//  PolyInclude.h
//  Livingroom
//
//  Created by Livingroom on 08/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Livingroom_PolyInclude_h
#define Livingroom_PolyInclude_h

#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Arr_segment_traits_2.h>
#include <CGAL/Arrangement_2.h>


#include <CGAL/Polygon_2.h>
//
////#include <CGAL/Projection_traits_xy_3.h>
//#include <CGAL/Constrained_Delaunay_triangulation_2.h>
//#include <CGAL/Delaunay_mesher_2.h>
//#include <CGAL/Delaunay_mesh_face_base_2.h>
//#include <CGAL/Delaunay_mesh_size_criteria_2.h>

typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
typedef CGAL::Arr_segment_traits_2<Kernel> Traits_2;
typedef CGAL::Polygon_2<Kernel>     Polygon_2;
typedef Traits_2::Point_2                  Point_2;
typedef Traits_2::X_monotone_curve_2       Segment_2;
typedef CGAL::Arrangement_2<Traits_2>      Arrangement_2;

//typedef CGAL::Triangulation_vertex_base_2<K> Vb;
//typedef CGAL::Delaunay_mesh_face_base_2<K> Fb;
//typedef CGAL::Triangulation_data_structure_2<Vb, Fb> Tds;
//typedef CGAL::Constrained_Delaunay_triangulation_2<K, Tds> CDT;
//typedef CGAL::Delaunay_mesh_size_criteria_2<CDT> Criteria;
//typedef CGAL::Delaunay_mesher_2<CDT, Criteria> Mesher;
//
//typedef CDT::Edge_iterator  Edge_iterator;
//
//typedef CDT::Vertex_handle Vertex_handle;
//typedef CDT::Point Point2;


#endif
