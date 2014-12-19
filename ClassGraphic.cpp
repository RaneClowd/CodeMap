#include "ClassGraphic.h"

ClassGraphic::ClassGraphic() {
    this->paintColor[0] = 0;
    this->paintColor[1] = 1;
    this->paintColor[2] = 1;

    this->rect.width = 300;
    this->rect.height = 300;
}

void ClassGraphic::addMethod(MethodObject *methodObj) {
    methodObj->rect.y = this->rect.y + 50;

    methodObj->rect.x = this->rect.x + this->newMethodOffset;
    this->newMethodOffset += 100;

    this->methodCollection.addItem(methodObj);
}

void ClassGraphic::paintGraphic(GtkWidget *widget, cairo_t* cr) {
    BaseObject::paintGraphic(widget, cr);

    for (int i=0; i<this->methodCollection.itemCount(); i++) {
        this->methodCollection.itemAtIndex(i)->paintGraphic(widget, cr);
    }
}
