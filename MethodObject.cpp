#include "MethodObject.h"

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

void MethodObject::addLine(string code) {
	LineObject *line = new LineObject(code);

	line->rect.x = 20;
	line->rect.y = this->newLineOffset;
	this->newLineOffset += 40;

	this->lines.push_back(line);

	this->expandForChildIfNeeded(line);
}

void MethodObject::paintGraphic(GtkWidget *widget, cairo_t* cr) {
    BaseObject::paintGraphic(widget, cr);

    cairo_save(cr);

    cairo_translate(cr, this->rect.x, this->rect.y);
    cairo_rectangle(cr, GRAPHIC_STROKE_WIDTH, 1, this->rect.width-(2*GRAPHIC_STROKE_WIDTH), this->rect.height-(2*GRAPHIC_STROKE_WIDTH));
    cairo_clip(cr);

    for (auto I = lines.begin(); I != lines.end(); ++I) {
        (*I)->paintGraphic(widget, cr);
    }

    cairo_restore(cr);
}
