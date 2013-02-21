import sys
sys.path.append('/Users/kennyskaggs/Projects/Clang/llvm/tools/clang/bindings/python/')
import clang.cindex

import objc
from Foundation import *
from AppKit import *

print 'handler loaded'
print ''

class ClangHandler(NSObject):
    
    def parseFile_(self, filePath):
        print 'received message to parse file:'
        print filePath

        index = clang.cindex.Index.create()
        tu = index.parse(filePath)
        
        self.rootNode = RootNode.alloc().init()

        for child in tu.cursor.get_children():
            self.traverseNode_(child)
    
        return self.rootNode

    def traverseNodeHelper_withIndent_(self, cursor, indent):
        self.processNode_withIndent_(cursor, indent)

    def traverseNode_(self, cursor):
        if (cursor.location.file is not None and cursor.location.file.name.startswith("/Users/kennyskaggs/Projects/Utilities/CodeMap")):

            self.traverseNodeHelper_withIndent_(cursor, '\t')
            

    def processNode_withIndent_(self, cursor, indent):
        if (cursor.kind.value == 11):
            print '%sinterface: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            openInterface = GraphNode.alloc().initWithType_andText_andHash_('Interface', cursor.displayname, cursor.hash)
            self.rootNode.addClass_IsInterfaceDefinition_(openInterface, True)
        
        elif (cursor.kind.value == 18):
            print '%sclass imp: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            openClass = GraphNode.alloc().initWithType_andText_andHash_('Implementation', cursor.displayname, cursor.hash)
            self.rootNode.addClass_IsInterfaceDefinition_(openClass, False)
    
        elif (cursor.kind.value == 16):
            print '%smethod decl: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            methodDecl = GraphNode.alloc().initWithType_andText_andHash_(2, cursor.displayname, cursor.hash)
            self.rootNode.addMethod_(methodDecl)
                
        elif (cursor.kind.value == 104 and cursor.get_definition() is not None):
            print '%smethod call (defined): %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            methodCall = GraphNode.alloc().initWithType_andText_andHash_('Invocation', cursor.displayname, cursor.get_definition().hash)
            self.rootNode.addMethodCall_(methodCall)
    
        elif (cursor.kind.value == 104):
            print '%smethod call to no def: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            methodCall = GraphNode.alloc().initWithType_andText_andHash_('Invocation', cursor.displayname, None)
            self.rootNode.addMethodCall_(methodCall)
                
        else:
            if (cursor.get_definition() is not None):
                print '%s%s %d decl=%d kind=%d' % (indent, cursor.displayname, cursor.hash, cursor.get_definition().hash, cursor.kind.value)
            elif (cursor.referenced is not None):
                print '%s%s %d ref=%d kind=%d refkind=%d' % (indent, cursor.displayname, cursor.hash, cursor.referenced.hash, cursor.kind.value, cursor.referenced.kind.value)
            else:
                print '%s%s %d kind=%d' % (indent, cursor.displayname, cursor.hash, cursor.kind.value)

        for c in cursor.get_children():
            self.traverseNodeHelper_withIndent_(c, indent+'\t')

class GraphNode(NSObject):
    
    def initWithType_andText_andHash_(self, value, disp, hash):
        self = super(GraphNode, self).init()
        self.subNodes = []
        self.decls = []
        self.value = value
        self.disp = disp
        self.hashVal = hash
        self.reference = None
        self.viewPlaceHolder = None
        self.container = None
        self.itemLookupTable = {}
        self.accessible = 'No'
        return self
    
    def appendChild_(self, child):
        self.subNodes.append(child)
        child.setParent_(self)
    
    def getChildren(self):
        return self.subNodes
    
    def appendDeclaration_(self, declaration):
        self.decls.append(declaration)
    
    def getDeclarations(self):
        return self.decls

    def getType(self):
        return self.value

    def getText(self):
        return self.disp

    def getHash(self):
        return self.hashVal

    def getView(self):
        return self.viewPlaceHolder

    def setView_(self, view):
        self.viewPlaceHolder = view

    def setObject_ForKey_(self, obj, key):
        self.itemLookupTable[key] = obj

    def getObjectForKey_(self, key):
        if (key in self.itemLookupTable):
            return self.itemLookupTable[key]
        else:
            return None

    def setTarget_(self, target):
        self.reference = target

    def getTarget(self):
        return self.reference
    
    def setParent_(self, parent):
        self.container = parent

    def getParent(self):
        return self.container

    def getPubliclyAccessible(self):
        return self.accessible

    def setPublic_(self, public):
        self.accessible = public

class InterfaceMerger(NSObject):

    def init(self):
        self.int = None
        self.imp = None
        return self

    def getImplementation(self):
        return self.imp

    def setImplementation_(self, implementation):
        self.imp = implementation
        if (self.int is not None):
            self.processSplitDefinition()

    def getInterface(self):
        return self.int

    def setInterface_(self, interface):
        self.int = interface
        if (self.imp is not None):
            self.processSplitDefinition()

    def processSplitDefinition(self):
        for methodNode in self.int.getChildren():
            methodImp = self.imp.getObjectForKey_(methodNode.getText())
            print 'int: %s:' % methodNode
            if (methodImp):
                methodImp.setPublic_('Yes')

class RootNode(GraphNode):

    def init(self):
        self = super(RootNode, self).initWithType_andText_andHash_(0, 'root', 0)
        self.recentClass = None
        self.recentMethod = None
        self.classHelpers = {}
        return self

    def lastClass(self):
        return self.recentClass

    def addClass_IsInterfaceDefinition_(self, classObj, isInterface):
        self.recentClass = classObj
        self.appendChild_(classObj)
    
        if (classObj.getText() in self.classHelpers):
            classHelper = self.classHelpers[classObj.getText()]
            self.setObject_OnClassHelper_IsInterface_(classObj, classHelper, isInterface)
            self.subNodes.remove(classHelper.getInterface())
        else:
            helper = InterfaceMerger.alloc().init()
            self.setObject_OnClassHelper_IsInterface_(classObj, helper, isInterface)
            self.classHelpers[classObj.getText()] = helper
    
    def setObject_OnClassHelper_IsInterface_(self, object, helper, isInt):
        print helper
        if (isInt):
            helper.setInterface_(object)
        else:
            helper.setImplementation_(object)
    
    def addProperty_(self, propertyNode):
        self.recentClass.appendDeclaration_(propertyNode)

    def lastMethod(self):
        return self.recentMethod

    def addMethod_(self, methodObj):
        if (self.recentClass is not None):
            self.recentMethod = methodObj
            self.recentClass.appendChild_(methodObj)

            self.recentClass.setObject_ForKey_(methodObj, methodObj.getText())

    def addMethodCall_(self, methodCallObj):
        if (self.recentMethod is not None):
            self.recentMethod.appendChild_(methodCallObj)