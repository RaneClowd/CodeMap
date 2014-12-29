/*
 * CodeLineObject.cpp
 *
 *  Created on: Dec 22, 2014
 *      Author: kennyskaggs
 */

#include "CodeLineObject.h"

#include <math.h>

CodeLineObject::CodeLineObject(string code) {
	BaseObject::BaseObject();

	rect.width = 250;

	this->paintColor[0] = 0;
	this->paintColor[1] = 1;
	this->paintColor[2] = 0;

	calledMethod = NULL;

	name = code;
}

CodeLineObject::~CodeLineObject() { }


GdkPoint CodeLineObject::locationForDot() {
	GdkPoint point;
	point.x = rect.width - (2*CONNECTOR_RADIUS);
	point.y = rect.height / 2;

	return point;
}

GdkPoint CodeLineObject::transformedConnectorLocation() {
	return transformedPointForSurroundingContext(locationForDot());
}

void CodeLineObject::paintGraphic(GtkWidget *widget, cairo_t* cr, vector<GdkPoint> *linePoints) {
    BaseObject::paintGraphic(widget, cr, linePoints);

    cairo_save(cr);

    cairo_translate(cr, this->rect.x, this->rect.y);
    GdkPoint dotCenter = locationForDot();
	cairo_arc(cr, dotCenter.x, dotCenter.y, CONNECTOR_RADIUS, 0, 2*M_PI);
	cairo_fill(cr);

    cairo_restore(cr);

    if (calledMethod) {
    	linePoints->push_back(transformedConnectorLocation());
    	linePoints->push_back(calledMethod->transformedConnectorLocation());
    }
}
