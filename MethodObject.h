#ifndef __METHOD_OBJECT_H
#define __METHOD_OBJECT_H

#include "BaseObject.h"
#include <vector>

#include "LineObject.h"

class MethodObject : public BaseObject {
    public:
        MethodObject();
        virtual ~MethodObject();

        void addLine(string code);
        void paintGraphic(GtkWidget *widget, cairo_t *cr);

    protected:
        vector<LineObject*> lines;
        int newLineOffset = 35;

    private:
};

#endif // __METHOD_OBJECT_H
