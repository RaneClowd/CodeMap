
#include <vector>
#include <gtk/gtk.h>

#include "Parser.h"
#include "ClassGraphic.h"
#include "MethodObject.h"

static GtkWidget *window = NULL;

static vector<ClassGraphic*> classes;
static BaseObject *selectedObject;
static int previousMouseX, previousMouseY;

static void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit();

    for (auto I = classes.begin(); I != classes.end(); ++I) {
    	g_print("freeing %s\n", (*I)->name.c_str());
		delete *I;
	}
}

static gboolean delete_event(GtkWidget *widget, GdkEvent *event, gpointer data) {
    gtk_main_quit();
    return FALSE;
}

static gboolean expose_event_callback(GtkWidget *widget, GdkEventExpose *event, gpointer data) {
    cairo_t *cr = gdk_cairo_create(widget->window);

    cairo_set_source_rgb(cr, 1, 1, 1);
    cairo_paint(cr);

    cairo_set_line_width(cr, 1);

    vector<GdkPoint> linePoints;
    for (auto I = classes.begin(); I != classes.end(); ++I) {
        (*I)->paintGraphic(widget, cr, &linePoints);
    }

    for (uint i=0; i<linePoints.size(); i+=2) {
    	cairo_move_to(cr, linePoints[i].x, linePoints[i].y);
    	cairo_line_to(cr, linePoints[i+1].x, linePoints[i+1].y);
    	cairo_stroke(cr);
    }

    cairo_destroy(cr);

    return FALSE;
}

static BaseObject* findSelectedObject(int x, int y) {
    for (auto I = classes.rbegin(); I != classes.rend(); ++I) {
        BaseObject *potentialObject = (*I)->objectAtPoint(x, y);
        if (potentialObject) return potentialObject;
    }

    return NULL;
}

static gint button_press_event(GtkWidget *widget, GdkEventButton *event) {
    if (event->button == 1) {
        int mouseX = event->x, mouseY = event->y;
        selectedObject = findSelectedObject(mouseX, mouseY);

        if (selectedObject) {
            previousMouseX = mouseX;
            previousMouseY = mouseY;
        }
    }

    return TRUE;
}

static gint button_release_event(GtkWidget *widget, GdkEventButton *event) {
    if (event->button == 1) {
        if (selectedObject && selectedObject->parentObj) {
        	selectedObject->parentObj->shrinkToFitChildrenIfPossible();
            gtk_widget_draw(widget, &(widget->allocation)); // TODO: Find a way to not redraw everything!!!
        }
    }

    return TRUE;
}

static gint motion_notify_event(GtkWidget *widget, GdkEventMotion *event) {
    if (event->state & GDK_BUTTON1_MASK && selectedObject) {
        int deltaX = event->x - previousMouseX, deltaY = event->y - previousMouseY;
        previousMouseX = event->x;
        previousMouseY = event->y;

        selectedObject->updateLocation(deltaX, deltaY, widget);
    }

    return TRUE;
}


GtkWidget* setUpDrawingWidgetInBox() {
    GtkWidget *topLevelBox = gtk_vbox_new(FALSE, 10);
    gtk_container_add(GTK_CONTAINER(window), topLevelBox);

    GtkWidget *drawing_area = gtk_drawing_area_new();

    gtk_widget_set_size_request(drawing_area, 1100, 600);
    g_signal_connect(G_OBJECT(drawing_area), "expose_event", G_CALLBACK(expose_event_callback), NULL);
    g_signal_connect(G_OBJECT(drawing_area), "motion_notify_event", G_CALLBACK(motion_notify_event), NULL);
    g_signal_connect(G_OBJECT(drawing_area), "button_press_event", G_CALLBACK(button_press_event), NULL);
    g_signal_connect(G_OBJECT(drawing_area), "button_release_event", G_CALLBACK(button_release_event), NULL);

    gtk_widget_add_events(drawing_area, GDK_POINTER_MOTION_MASK | GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK);

    gtk_box_pack_start(GTK_BOX(topLevelBox), drawing_area, TRUE, TRUE, 0);
    gtk_widget_show(drawing_area);

    return topLevelBox;
}

void addButtonsToBox(GtkWidget* box) {
    GtkWidget *subbox = gtk_hbox_new(FALSE, 10);
    gtk_box_pack_start(GTK_BOX(box), subbox, TRUE, TRUE, 0);

    GtkWidget *button = gtk_button_new_with_label("Load");
    //g_signal_connect(button, "clicked", G_CALLBACK(callback), (gpointer)"button 1");
    gtk_box_pack_start(GTK_BOX(subbox), button, TRUE, TRUE, 0);
    gtk_widget_show(button);

    button = gtk_button_new_with_label("Quit");
    g_signal_connect_swapped(button, "clicked", G_CALLBACK(gtk_widget_destroy), window);
    gtk_box_pack_end(GTK_BOX(subbox), button, TRUE, TRUE, 0);
    gtk_widget_show(button);

    gtk_widget_show(subbox);
}

void setUpGtkWindow() {
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Code Map!");
    gtk_container_set_border_width(GTK_CONTAINER(window), 5);
    g_signal_connect(window, "destroy", G_CALLBACK(destroy), NULL);

    g_signal_connect(window, "delete-event", G_CALLBACK(delete_event), NULL);

    GtkWidget *topLevelBox = setUpDrawingWidgetInBox();
    addButtonsToBox(topLevelBox);
    gtk_widget_show(topLevelBox);

    gtk_widget_show(window);
}

int main(int argc, const char **argv) {
	classes = Parser::classesFromFile(argc, argv);

    char **conv = const_cast<char **>(argv);
    gtk_init(&argc, &conv);

    setUpGtkWindow();
    gtk_main();

    return 0;
}
