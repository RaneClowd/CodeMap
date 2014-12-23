#include "BaseObject.h"

BaseObject::BaseObject() {
    this->parentObj = NULL;

    this->rect.width = 130;
    this->rect.height = 30;
}

BaseObject::~BaseObject() { }

BaseObject* BaseObject::objectAtPoint(int x, int y) {
    if (this->rect.x <= x && this->rect.y <= y && this->rect.width + this->rect.x >= x && this->rect.height + this->rect.y >= y) {
    	return this;
    } else {
    	return NULL;
    }
}

void BaseObject::paintGraphic(GtkWidget *widget, cairo_t *cr, vector<GdkPoint> *linePoints) {
    cairo_set_source_rgb(cr, this->paintColor[0], this->paintColor[1], this->paintColor[2]);

    cairo_rectangle(cr, this->rect.x, this->rect.y, this->rect.width, this->rect.height);
    cairo_fill_preserve(cr);

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_stroke(cr);

    cairo_select_font_face(cr, "Georgia", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 14);

    cairo_move_to(cr, this->rect.x + 10, this->rect.y + 20);
    cairo_show_text(cr, this->name.c_str());
}

void BaseObject::expandForChildIfNeeded(BaseObject *child) {
	if (child->rect.x + child->rect.width > this->rect.width - OBJECT_CONTAINER_MARGIN) {
		// Need to expand towards the right
		this->rect.width = child->rect.x + child->rect.width + OBJECT_CONTAINER_MARGIN;
	}
	if (child->rect.x < OBJECT_CONTAINER_MARGIN) {
		// Need to shift to left (and expand to keep right border in place)
		int leftShift = OBJECT_CONTAINER_MARGIN - child->rect.x;
		this->rect.x -= leftShift;
		this->rect.width += leftShift;

		this->shiftAllItems(leftShift, 0);
	}

	if (child->rect.y + child->rect.height > this->rect.height - OBJECT_CONTAINER_MARGIN) {
		// Need to expand downwards
		this->rect.height = child->rect.y + child->rect.height + OBJECT_CONTAINER_MARGIN;
	}
	if (child->rect.y < TOP_MARGIN) {
		// Need to shift up (and expand to keep bottom border in place)
		int upShift = TOP_MARGIN - child->rect.y;
		this->rect.y -= upShift;
		this->rect.height += upShift;

		this->shiftAllItems(0, upShift);
	}
}

void BaseObject::updateLocation(int deltaX, int deltaY, GtkWidget *widget) {
    this->rect.x += deltaX; this->rect.y += deltaY;
    if (this->parentObj) {
    	this->parentObj->expandForChildIfNeeded(this);
    }

    gtk_widget_draw(widget, &(widget->allocation)); // TODO: Find a way to not redraw everything!!!
}

GdkPoint BaseObject::transformedPointForSurroundingContext(GdkPoint point) {
	point.x += rect.x;
	point.y += rect.y;

	if (parentObj) {
		return parentObj->transformedPointForSurroundingContext(point);
	} else {
		return point;
	}
}

GdkPoint BaseObject::locationForDot() {
	return GdkPoint();
}

GdkPoint BaseObject::transformedConnectorLocation() {
	return GdkPoint();
}
