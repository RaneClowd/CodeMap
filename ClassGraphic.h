#ifndef __CLASS_GRAPHIC_H
#define __CLASS_GRAPHIC_H

#include "BaseObject.h"
#include "MethodObject.h"
#include "Collection.h"

class ClassGraphic : public BaseObject {

public:
    ClassGraphic();
    void addMethod(MethodObject *methodObj);
    void paintGraphic(GtkWidget *widget, cairo_t *cr);

protected:
    Collection<MethodObject> methodCollection;
    int newMethodOffset = 50;

};

#endif
