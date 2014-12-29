#include "MethodObject.h"

#include <math.h>

MethodObject::MethodObject() {
	BaseObject::BaseObject();

    this->paintColor[0] = 0;
    this->paintColor[1] = 1;
    this->paintColor[2] = 136.0f / 255.0f;
}

MethodObject::~MethodObject() {
	BaseObject::~BaseObject();

	for (auto I = this->lines.begin(); I != this->lines.end(); ++I) {
		delete *I;
	}
}

CodeLineObject* MethodObject::addLine(string code) {
	CodeLineObject *line = new CodeLineObject(code);

	line->rect.x = 20;
	line->rect.y = this->newLineOffset;
	line->parentObj = this;
	this->newLineOffset += 40;

	this->lines.push_back(line);

	this->expandForChildIfNeeded(line);

	return line;
}

GdkPoint MethodObject::locationForDot() {
	GdkPoint point;
	point.x = 2*CONNECTOR_RADIUS;
	point.y = 2*CONNECTOR_RADIUS;

	return point;
}

GdkPoint MethodObject::transformedConnectorLocation() {
	return transformedPointForSurroundingContext(locationForDot());
}

void MethodObject::paintGraphic(GtkWidget *widget, cairo_t* cr, vector<GdkPoint> *linePoints) {
    BaseObject::paintGraphic(widget, cr, linePoints);

    cairo_save(cr);

    cairo_translate(cr, this->rect.x, this->rect.y);
    cairo_rectangle(cr, GRAPHIC_STROKE_WIDTH, 1, this->rect.width-(2*GRAPHIC_STROKE_WIDTH), this->rect.height-(2*GRAPHIC_STROKE_WIDTH));
    cairo_clip(cr);

    for (auto I = lines.begin(); I != lines.end(); ++I) {
        (*I)->paintGraphic(widget, cr, linePoints);
    }

    GdkPoint dotCenter = locationForDot();
    cairo_arc(cr, dotCenter.x, dotCenter.y, CONNECTOR_RADIUS, 0, 2*M_PI);
    cairo_fill(cr);

    cairo_restore(cr);
}
