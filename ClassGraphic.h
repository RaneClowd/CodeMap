#ifndef __CLASS_GRAPHIC_H
#define __CLASS_GRAPHIC_H

#include <vector>

#include "BaseObject.h"
#include "MethodObject.h"

class ClassGraphic : public BaseObject {

public:
    ClassGraphic();
    ~ClassGraphic();

    void addMethod(MethodObject *methodObj);

    void paintGraphic(GtkWidget *widget, cairo_t *cr);
    BaseObject* objectAtPoint(int x, int y);

    void shrinkToFitChildrenIfPossible();

protected:
    std::vector<MethodObject*> methods;
    int newMethodOffset = OBJECT_CONTAINER_MARGIN;
    void shiftAllItems(int deltaX, int deltaY);

};

#endif
