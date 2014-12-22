#ifndef __BASE_OBJECT_H
#define __BASE_OBJECT_H

#include <iostream>
#include <gtk/gtk.h>

using namespace std;

const int GRAPHIC_STROKE_WIDTH = 1;
const int OBJECT_CONTAINER_MARGIN = 15;

class BaseObject {
    public:
        BaseObject();
        virtual ~BaseObject();

        GdkRectangle rect;
        string name;
        BaseObject *parentObj;

        virtual void paintGraphic(GtkWidget *widget, cairo_t *cr);

        void updateLocation(int deltaX, int deltaY, GtkWidget *widget);
        virtual BaseObject* objectAtPoint(int x, int y);

        virtual void shrinkToFitChildrenIfPossible() { };

    protected:
        float paintColor[3];
        virtual void expandForChildIfNeeded(BaseObject *child);
        virtual void shiftAllItems(int deltaX, int deltaY) { };

    private:
};

#endif // __BASE_OBJECT_H
