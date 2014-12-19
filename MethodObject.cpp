#include "MethodObject.h"

MethodObject::MethodObject() {
    this->paintColor[0] = 0;
    this->paintColor[1] = 1;
    this->paintColor[2] = 110.0f / 255.0f;

    this->rect.width = 200;
    this->rect.height = 200;
}

MethodObject::~MethodObject() { }
