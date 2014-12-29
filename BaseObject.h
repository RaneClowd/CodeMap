#ifndef __BASE_OBJECT_H
#define __BASE_OBJECT_H

#include <vector>
#include <iostream>
#include <gtk/gtk.h>

using namespace std;

const int GRAPHIC_STROKE_WIDTH = 1;
const int OBJECT_CONTAINER_MARGIN = 15;
const int TOP_MARGIN = 40;
const int CONNECTOR_RADIUS = 2;

class BaseObject {
    public:
        BaseObject();
        virtual ~BaseObject();

        GdkRectangle rect;
        string name;
        BaseObject *parentObj;

        virtual void paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints);

        void updateLocation(int deltaX, int deltaY, GtkWidget *widget);
        virtual BaseObject* objectAtPoint(int x, int y);

        virtual void shrinkToFitChildrenIfPossible() { };
        void expandForChildIfNeeded(BaseObject *child);

        virtual GdkPoint locationForDot();
        virtual GdkPoint transformedConnectorLocation();

    protected:
        float paintColor[3];
        virtual void shiftAllItems(int deltaX, int deltaY) { };

        virtual GdkPoint transformedPointForSurroundingContext(GdkPoint point);

    private:
};

#endif // __BASE_OBJECT_H
