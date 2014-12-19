#ifndef __BASE_OBJECT_H
#define __BASE_OBJECT_H

#include <iostream>
#include <gtk/gtk.h>

using namespace std;

class BaseObject {
    public:
        BaseObject();
        virtual ~BaseObject();

        GdkRectangle rect;
        string name;

        bool containsPoint(int x, int y);
        void updateLocation(int x, int y, GtkWidget *widget);
        virtual void paintGraphic(GtkWidget *widget, cairo_t *cr);

    protected:
        float paintColor[3];

    private:
};

#endif // __BASE_OBJECT_H
