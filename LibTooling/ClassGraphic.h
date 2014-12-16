#ifndef CLASS_GRAPHIC_H
#define CLASS_GRAPHIC_H

#include <iostream>
#include <gtk/gtk.h>

using namespace std;


class ClassGraphic {
    
public:
    ClassGraphic();
    GdkRectangle rect;
    string name;
    
    bool containsPoint(int x, int y);
    void updateLocation(int x, int y, GtkWidget *widget, GdkPixmap *pixmap);
    
    GdkGC *gc;
    GdkGC *eraseGc;
    
};

#endif