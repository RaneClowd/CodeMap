#ifndef __METHOD_OBJECT_H
#define __METHOD_OBJECT_H

#include "BaseObject.h"
#include <vector>

#include "CodeLineObject.h"

class MethodObject : public BaseObject {
    public:
        MethodObject();
        virtual ~MethodObject();

        CodeLineObject* addLine(string code);
        void paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints);

        GdkPoint locationForDot();
        GdkPoint transformedConnectorLocation();

    protected:
        vector<CodeLineObject*> lines;
        int newLineOffset = TOP_MARGIN;

    private:
};

#endif // __METHOD_OBJECT_H
