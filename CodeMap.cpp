#include "clang/Frontend/FrontendActions.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Lex/Lexer.h"

#include <vector>
#include <gtk/gtk.h>

#include "ClassGraphic.h"
#include "MethodObject.h"

using namespace clang::tooling;
using namespace clang;
using namespace llvm;

ClassGraphic* classGraphicForName(string name);

// Apply a custom category to all command-line options so that they are the
// only ones displayed.
static llvm::cl::OptionCategory MyToolCategory("my-tool options");

// CommonOptionsParser declares HelpMessage with a description of the common
// command-line options related to the compilation database and input files.
// It's nice to have this help message in all tools.
static cl::extrahelp CommonHelp(CommonOptionsParser::HelpMessage);

// A help message for this specific tool can be added afterwards.
static cl::extrahelp MoreHelp("\nMore help text...");

class FindNamedClassVisitor : public RecursiveASTVisitor<FindNamedClassVisitor> {
public:
	explicit FindNamedClassVisitor(ASTContext *Context) : Context(Context) {}

    /*bool VisitObjCContainerDecl(ObjCContainerDecl *declaration) {
        //declaration->dump();

        *if (declaration->getQualifiedNameAsString() == "n::m::C") {
            FullSourceLoc fullSourceLoc = Context->getFullLoc(declaration->getLocStart());
            if (fullSourceLoc.isValid()) {
                llvm::outs() << "Found declaration at " << fullSourceLoc.getSpellingLineNumber() << ":" << fullSourceLoc.getSpellingColumnNumber() << "\n";
            }
        }*\/

        llvm::outs() << "\t\tcontainer: " << declaration->getQualifiedNameAsString() << "\n";

        return true;
    }*/

    MethodObject* processObjCMethodDecl(ObjCMethodDecl *declaration, ClassGraphic *classGraphic) {
        MethodObject *newMethodObj = new MethodObject();
        newMethodObj->name = declaration->getNameAsString();

        llvm::outs() << "\tmethod: " << declaration->getQualifiedNameAsString() << "\n";

        if (declaration->isThisDeclarationADefinition()) {
            //declaration->dump();
            if (declaration->hasBody()) {
                MethodObject *methodObj = classGraphic->methodForSignature(declaration->getNameAsString());

                CompoundStmt *body = (CompoundStmt*)declaration->getBody();

                for (CompoundStmt::body_iterator I = body->body_begin(), E = body->body_end(); I != E; ++I) {
                    Stmt *statement = *I;

                    string code = Lexer::getSourceText(CharSourceRange::getTokenRange(statement->getSourceRange()), Context->getSourceManager(), LangOptions(), 0);
                    LineObject *lineObj = methodObj->addLine(code);

                    if (isa<ObjCMessageExpr>(statement)) {
                        ObjCMessageExpr *messageExpr = static_cast<ObjCMessageExpr*>(statement);
                        ObjCInterfaceDecl *receiverInterface = messageExpr->getReceiverInterface();
                        if (receiverInterface) {
                            llvm::outs() << "\t\tcalls to:\t" << receiverInterface->getObjCRuntimeNameAsString() << "\t\t\t" << messageExpr->getSelector().getAsString() << "\n";

                            ClassGraphic *calledClass = classGraphicForName(receiverInterface->getQualifiedNameAsString());
                            MethodObject *calledMethod = calledClass->methodForSignature(messageExpr->getSelector().getAsString());
                            calledClass->expandForChildIfNeeded(calledMethod);

                            lineObj->calledMethod = calledMethod;
                        } else {
                            llvm::outs() << "\t\tcalls to:\t(unknown)\t\t\t" << messageExpr->getSelector().getAsString() << "\n";
                        }
                    }
                }

                return methodObj;
            }

            llvm::outs() << "\n";
        }

        g_print("warning: unused method\n");
        return NULL;
    }

    bool VisitObjCImplDecl(ObjCImplDecl *implDecl) {
        llvm::outs() << "impl: " << implDecl->getNameAsString() << "\n";

        ClassGraphic *classGraphic = classGraphicForName(implDecl->getQualifiedNameAsString());
        for (ObjCContainerDecl::method_iterator method = implDecl->meth_begin(), last_method = implDecl->meth_end(); method != last_method; ++method) {
            MethodObject *methodObj = processObjCMethodDecl(*method, classGraphic);
            if (methodObj) {
                classGraphic->expandForChildIfNeeded(methodObj);
            }

        }

        g_print("\n");

        return true;
    }

    /*bool VisitStmt(Stmt *statement) {
        llvm::outs() << "s:\t\t" << statement->getStmtClassName() << "\n";

        // child iterator

        return true;
    }*/

    /*bool VisitObjCMessageExpr(ObjCMessageExpr *messageExpr) {
        // sees things like uses of CGRectMake(...)

        ObjCInterfaceDecl *receiverInterface = messageExpr->getReceiverInterface();
        if (receiverInterface) {
            llvm::outs() << "\t\t\t\tcall to:\t\t" << receiverInterface->getObjCRuntimeNameAsString() << "\t\t\t" << messageExpr->getSelector().getAsString() << "\n";
        } else {
            llvm::outs() << "\t\t\t\tcall to:\t\t(unknown)\t\t\t" << messageExpr->getSelector().getAsString() << "\n";
        }

        return true;
    }*/

private:
    ASTContext *Context;
};

class FindNamedClassConsumer : public ASTConsumer {
public:
    explicit FindNamedClassConsumer(ASTContext *Context) : Visitor(Context) {}

    /*virtual bool HandleTopLevelDecl(DeclGroupRef dr) {
        for (DeclGroupRef::iterator b = dr.begin(), e = dr.end(); b != e; ++b) {
            Visitor.TraverseDecl(*b);
            //(*b)->dump();
        }

        return true;
    }*/

    virtual void HandleTranslationUnit(ASTContext &Context) {
        Visitor.TraverseDecl(Context.getTranslationUnitDecl());
    }

private:
    FindNamedClassVisitor Visitor;
};

class FindNamedClassAction : public ASTFrontendAction {
public:
    virtual std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler, llvm::StringRef InFile) {
        return std::unique_ptr<ASTConsumer>(new FindNamedClassConsumer(&(Compiler.getASTContext())));
    }
};



static GtkWidget *window = NULL;

static BaseObject *selectedObject;
static int previousMouseX, previousMouseY;

static std::vector<ClassGraphic*> classGraphics;

ClassGraphic* classGraphicForName(string name) {
    for (auto I = classGraphics.begin(); I != classGraphics.end(); ++I) {
        ClassGraphic *classGraphic = *I;
        if (classGraphic->name.compare(name) == 0) {
            return classGraphic;
        }
    }

    ClassGraphic *newClassGraphic = new ClassGraphic();

    newClassGraphic->name = name;

    static int xPosition = 50;
    newClassGraphic->rect.x = xPosition;
    xPosition += 100;

    newClassGraphic->rect.y = 100;

    classGraphics.push_back(newClassGraphic);
    return newClassGraphic;
}

static void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit();

    for (auto I = classGraphics.rbegin(); I != classGraphics.rend(); ++I) {
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
    for (auto I = classGraphics.begin(); I != classGraphics.end(); ++I) {
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
    for (auto I = classGraphics.rbegin(); I != classGraphics.rend(); ++I) {
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

    gtk_widget_set_size_request(drawing_area, 1000, 500);
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
    CommonOptionsParser OptionsParser(argc, argv, MyToolCategory);
    ClangTool Tool(OptionsParser.getCompilations(),
                   OptionsParser.getSourcePathList());
    Tool.run(newFrontendActionFactory<FindNamedClassAction>().get());


    char **conv = const_cast<char **>(argv);
    gtk_init(&argc, &conv);

    setUpGtkWindow();
    gtk_main();

    return 0;
}
