/*
 * LineObject.cpp
 *
 *  Created on: Dec 22, 2014
 *      Author: kennyskaggs
 */

#include "LineObject.h"

LineObject::LineObject(string code) {
	BaseObject::BaseObject();

	rect.width = 250;

	this->paintColor[0] = 0;
	this->paintColor[1] = 1;
	this->paintColor[2] = 0;

	name = code;
}

LineObject::~LineObject() { }

