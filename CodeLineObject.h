/*
 * CodeLineObject.h
 *
 *  Created on: Dec 22, 2014
 *      Author: kennyskaggs
 */

#ifndef __CODE_LINE_OBJECT_H_
#define __CODE_LINE_OBJECT_H_

#include "BaseObject.h"

class CodeLineObject: public BaseObject {
public:
	CodeLineObject(string code);
	virtual ~CodeLineObject();

	BaseObject *calledMethod;

	void paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints);

    GdkPoint locationForDot();
    GdkPoint transformedConnectorLocation();
};

#endif /* __CODE_LINE_OBJECT_H_ */
