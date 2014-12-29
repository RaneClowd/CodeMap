/*
 * Parser.cpp
 *
 *  Created on: Dec 24, 2014
 *      Author: kennyskaggs
 */

#include "clang/Frontend/FrontendActions.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Lex/Lexer.h"

#include <vector>

#include "Parser.h"

using namespace clang::tooling;
using namespace clang;
using namespace llvm;

ClassGraphic* classGraphicForName(string name);

static vector<ClassGraphic*> classes;

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
	explicit FindNamedClassVisitor(ASTContext *Context) : Context(Context) { }

    MethodObject* processObjCMethodDecl(ObjCMethodDecl *declaration, ClassGraphic *classGraphic) {
        MethodObject *newMethodObj = new MethodObject();
        newMethodObj->name = declaration->getNameAsString();

        llvm::outs() << "\tmethod: " << declaration->getQualifiedNameAsString() << "\n";

        if (declaration->isThisDeclarationADefinition()) {
            if (declaration->hasBody()) {
                MethodObject *methodObj = classGraphic->methodForSignature(declaration->getNameAsString());

                CompoundStmt *body = (CompoundStmt*)declaration->getBody();

                for (auto I = body->body_begin(); I != body->body_end(); ++I) {
                    Stmt *statement = *I;

                    string code = Lexer::getSourceText(CharSourceRange::getTokenRange(statement->getSourceRange()), Context->getSourceManager(), LangOptions(), 0);
                    CodeLineObject *lineObj = methodObj->addLine(code);

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
                    } else {
                    	g_print("dumping code: %s\n", code.c_str());
                    	statement->dump();
                    	g_print("\n");
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
    explicit FindNamedClassConsumer(ASTContext *Context) : Visitor(Context) { }

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

ClassGraphic* classGraphicForName(string name) {
    for (auto I = classes.begin(); I != classes.end(); ++I) {
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

    classes.push_back(newClassGraphic);
    return newClassGraphic;
}

vector<ClassGraphic*> Parser::classesFromFile(int argc, const char **argv) {
	// TODO: clear out the vector for next use (works fine for one shot)

	CommonOptionsParser OptionsParser(argc, argv, MyToolCategory);
	ClangTool Tool(OptionsParser.getCompilations(), OptionsParser.getSourcePathList());
	Tool.run(newFrontendActionFactory<FindNamedClassAction>().get());

	return classes;
}
