#include "clang/Frontend/FrontendActions.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"

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

int main(int argc, const char **argv) {
    CommonOptionsParser OptionsParser(argc, argv, MyToolCategory);
    ClangTool Tool(OptionsParser.getCompilations(),
                   OptionsParser.getSourcePathList());
    return Tool.run(newFrontendActionFactory<FindNamedClassAction>().get());
    
    /*if (argc > 1) {
        runToolOnCode(new FindNamedClassAction, argv[1]);
    }*/
}