#ifndef __CLASS_GRAPHIC_H
#define __CLASS_GRAPHIC_H

#include <vector>

#include "BaseObject.h"
#include "MethodObject.h"

class ClassGraphic : public BaseObject {

public:
    ClassGraphic();
    void addMethod(MethodObject *methodObj);
    void paintGraphic(GtkWidget *widget, cairo_t *cr);

protected:
    std::vector<MethodObject*> methods;
    int newMethodOffset = 50;

};

#endif
