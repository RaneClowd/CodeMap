#include "ClassGraphic.h"

ClassGraphic::ClassGraphic() {
    
}

bool ClassGraphic::containsPoint(int x, int y) {
    return this->rect.x <= x && this->rect.y <= y && this->rect.width + this->rect.x >= x && this->rect.height + this->rect.y >= y;
}

void ClassGraphic::updateLocation(int x, int y, GtkWidget *widget, GdkPixmap *pixmap) {
    gdk_draw_rectangle(pixmap, this->eraseGc, TRUE, this->rect.x, this->rect.y, this->rect.width, this->rect.height);
    gtk_widget_draw(widget, &(this->rect));
    
    this->rect.x = x; this->rect.y = y;
    
    gdk_draw_rectangle(pixmap, this->gc, TRUE, this->rect.x, this->rect.y, this->rect.width, this->rect.height);
    gtk_widget_draw(widget, &(this->rect));
}