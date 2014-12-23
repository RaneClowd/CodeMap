/*
 * LineObject.h
 *
 *  Created on: Dec 22, 2014
 *      Author: kennyskaggs
 */

#ifndef __LINE_OBJECT_H_
#define __LINE_OBJECT_H_

#include "BaseObject.h"

class LineObject: public BaseObject {
public:
	LineObject(string code);
	virtual ~LineObject();

	BaseObject *calledMethod;

	void paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints);

    GdkPoint locationForDot();
    GdkPoint transformedConnectorLocation();
};

#endif /* __LINE_OBJECT_H_ */
