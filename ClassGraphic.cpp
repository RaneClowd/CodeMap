#include "ClassGraphic.h"

#include <gtk/gtk.h>

ClassGraphic::ClassGraphic() {
	BaseObject::BaseObject();

    this->paintColor[0] = 0;
    this->paintColor[1] = 1;
    this->paintColor[2] = 1;
}

ClassGraphic::~ClassGraphic() {
	BaseObject::~BaseObject();

	for (auto I = methods.begin(); I != methods.end(); ++I) {
		// delete *I; TODO: figure out how to not fail at this (keeps telling me that the "pointer was never allocated")
	}
}

MethodObject* ClassGraphic::methodForSignature(string signature) {
	for (auto I = methods.begin(); I != methods.end(); ++I) {
		if ((*I)->name.compare(signature) == 0) {
			return (*I);
		}
	}

    MethodObject *newMethodObj = new MethodObject();
    newMethodObj->name = signature;

    newMethodObj->parentObj = this;
    newMethodObj->rect.y = TOP_MARGIN;
    newMethodObj->rect.x = this->newMethodOffset;
	this->newMethodOffset += 50;

	this->methods.push_back(newMethodObj);

	return newMethodObj;
}

BaseObject* ClassGraphic::objectAtPoint(int x, int y) {
	if (BaseObject::objectAtPoint(x, y)) {
		for (auto I = this->methods.rbegin(); I != methods.rend(); ++I) {
			BaseObject *obj = (*I)->objectAtPoint(x - this->rect.x, y - this->rect.y);
			if (obj) return obj;
		}
		return this;
	} else {
		return NULL;
	}
}

void ClassGraphic::paintGraphic(GtkWidget *widget, cairo_t* cr, vector<GdkPoint> *linePoints) {
    BaseObject::paintGraphic(widget, cr, linePoints);

    cairo_save(cr);

    cairo_translate(cr, this->rect.x, this->rect.y);
    cairo_rectangle(cr, GRAPHIC_STROKE_WIDTH, 1, this->rect.width-(2*GRAPHIC_STROKE_WIDTH), this->rect.height-(2*GRAPHIC_STROKE_WIDTH));
    cairo_clip(cr);

    for (auto I = this->methods.begin(); I != methods.end(); ++I) {
        (*I)->paintGraphic(widget, cr, linePoints);
    }

    cairo_restore(cr);
}

void ClassGraphic::shrinkToFitChildrenIfPossible() {
	int lowestX = rect.width, lowestY = rect.height, mostRight = 0, mostBottom = 0;
	for (auto I = this->methods.begin(); I != methods.end(); ++I) {
		GdkRectangle childRect = (*I)->rect;
		if (lowestX > childRect.x) {
			lowestX = childRect.x;
		}
		if (mostRight < childRect.x + childRect.width) {
			mostRight = childRect.x + childRect.width;
		}

		if (lowestY > childRect.y) {
			lowestY = childRect.y;
		}
		if (mostBottom < childRect.y + childRect.height) {
			mostBottom = childRect.y + childRect.height;
		}
	}

	int rightShift = lowestX - OBJECT_CONTAINER_MARGIN;
	rect.x += rightShift;

	int downShift = lowestY - TOP_MARGIN;
	rect.y += downShift;

	if (rightShift > 0 || downShift > 0) {
		shiftAllItems(-rightShift, -downShift);

		mostRight -= rightShift;
		mostBottom -= downShift;
	}

	rect.width = mostRight + OBJECT_CONTAINER_MARGIN;
	rect.height = mostBottom + OBJECT_CONTAINER_MARGIN;
}

void ClassGraphic::shiftAllItems(int deltaX, int deltaY) {
	for (auto I = this->methods.begin(); I != methods.end(); ++I) {
		(*I)->rect.x += deltaX;
		(*I)->rect.y += deltaY;
	}
}
