#ifndef __METHOD_OBJECT_H
#define __METHOD_OBJECT_H

#include "BaseObject.h"
#include <vector>

#include "LineObject.h"

class MethodObject : public BaseObject {
    public:
        MethodObject();
        virtual ~MethodObject();

        LineObject* addLine(string code);
        void paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints);

        GdkPoint locationForDot();
        GdkPoint transformedConnectorLocation();

    protected:
        vector<LineObject*> lines;
        int newLineOffset = TOP_MARGIN;

    private:
};

#endif // __METHOD_OBJECT_H
