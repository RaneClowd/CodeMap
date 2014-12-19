#include "BaseObject.h"

BaseObject::BaseObject() {
    //ctor
}

BaseObject::~BaseObject() { }

bool BaseObject::containsPoint(int x, int y) {
    return this->rect.x <= x && this->rect.y <= y && this->rect.width + this->rect.x >= x && this->rect.height + this->rect.y >= y;
}

void BaseObject::paintGraphic(GtkWidget *widget, cairo_t *cr) {
    cairo_set_source_rgb(cr, this->paintColor[0], this->paintColor[1], this->paintColor[2]);

    cairo_rectangle(cr, this->rect.x, this->rect.y, this->rect.width, this->rect.height);
    cairo_fill(cr);


    cairo_select_font_face(cr, "Georgia", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 14);

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_move_to(cr, this->rect.x, this->rect.y + 20);
    cairo_show_text(cr, this->name.c_str());
}

void BaseObject::updateLocation(int x, int y, GtkWidget *widget) {
    this->rect.x = x; this->rect.y = y;
    gtk_widget_draw(widget, &(widget->allocation)); // TODO: Find a way to not redraw everything!!!
}
