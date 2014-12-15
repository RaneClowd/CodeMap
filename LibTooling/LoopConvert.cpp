#include "clang/Frontend/FrontendActions.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include <gtk/gtk.h>

using namespace clang::tooling;
using namespace clang;
using namespace llvm;

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
    
    bool VisitObjCMethodDecl(ObjCMethodDecl *declaration) {
        llvm::outs() << "method: " << declaration->getQualifiedNameAsString() << "\n";
        
        if (declaration->isThisDeclarationADefinition()) {
            //declaration->dump();
            if (declaration->hasBody()) {
                CompoundStmt *body = (CompoundStmt*)declaration->getBody();
                
                for (CompoundStmt::body_iterator I = body->body_begin(), E = body->body_end(); I != E; ++I) {
                    
                    Stmt *statement = *I;
                    
                    if (isa<ObjCMessageExpr>(statement)) {
                        ObjCMessageExpr *messageExpr = static_cast<ObjCMessageExpr*>(statement);
                        ObjCInterfaceDecl *receiverInterface = messageExpr->getReceiverInterface();
                        if (receiverInterface) {
                            llvm::outs() << "\t\tcalls to:\t\t" << receiverInterface->getObjCRuntimeNameAsString() << "\t\t" << messageExpr->getSelector().getAsString() << "\n";
                        } else {
                            llvm::outs() << "\t\tcalls to:\t\t(unknown)\t\t" << messageExpr->getSelector().getAsString() << "\n";
                        }
                    }
                }
            }
            
            llvm::outs() << "\n";
        }
        
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
    //ASTContext *Context;
};

class FindNamedClassConsumer : public ASTConsumer {
public:
    explicit FindNamedClassConsumer(ASTContext *Context) : Visitor() {}
    
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
static GdkPixmap *pixmap = NULL;

static GdkRectangle boxRect;

static void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit();
}

static gboolean delete_event(GtkWidget *widget, GdkEvent *event, gpointer data) {
    gtk_main_quit();
    return FALSE;
}

static gint configure_event (GtkWidget *widget, GdkEventConfigure *event) {
    if (pixmap) gdk_pixmap_unref(pixmap);
    pixmap = gdk_pixmap_new(widget->window, widget->allocation.width, widget->allocation.height, -1);
    
    boxRect.x = 250; boxRect.y = 100;
    boxRect.width = 150; boxRect.height = 70;
    
    gdk_draw_rectangle(pixmap, widget->style->white_gc, TRUE, 0, 0, widget->allocation.width, widget->allocation.height);
    gdk_draw_rectangle(pixmap, widget->style->black_gc, TRUE, boxRect.x, boxRect.y, boxRect.width, boxRect.height);
    
    return TRUE;
}

static gboolean expose_event_callback(GtkWidget *widget, GdkEventExpose *event, gpointer data) {
    gdk_draw_pixmap(widget->window, widget->style->fg_gc[GTK_WIDGET_STATE(widget)], pixmap, event->area.x, event->area.y, event->area.x, event->area.y, event->area.width, event->area.height);
    
    return FALSE;
}

static gint motion_notify_event(GtkWidget *widget, GdkEventMotion *event) {
    if (event->state & GDK_BUTTON1_MASK) {
        int x = event->x, y = event->y;
        
        gdk_draw_rectangle(pixmap, widget->style->white_gc, TRUE, boxRect.x, boxRect.y, boxRect.width, boxRect.height);
        gtk_widget_draw(widget, &boxRect);
        
        boxRect.x = x - (boxRect.width / 2); boxRect.y = y - (boxRect.height / 2);
        
        gdk_draw_rectangle(pixmap, widget->style->black_gc, TRUE, boxRect.x, boxRect.y, boxRect.width, boxRect.height);
        gtk_widget_draw(widget, &boxRect);
    }
    
    return TRUE;
}


GtkWidget* setUpDrawingWidgetInBox() {
    GtkWidget *topLevelBox = gtk_vbox_new(FALSE, 10);
    gtk_container_add(GTK_CONTAINER(window), topLevelBox);
    
    GtkWidget *drawing_area = gtk_drawing_area_new();
    
    gtk_widget_set_size_request(drawing_area, 500, 500);
    g_signal_connect(G_OBJECT(drawing_area), "expose_event", G_CALLBACK(expose_event_callback), NULL);
    g_signal_connect(G_OBJECT(drawing_area), "configure_event", G_CALLBACK(configure_event), NULL);
    g_signal_connect(G_OBJECT(drawing_area), "motion_notify_event", G_CALLBACK(motion_notify_event), NULL);
    
    gtk_widget_add_events(drawing_area, GDK_POINTER_MOTION_MASK | GDK_BUTTON_PRESS_MASK);
    
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