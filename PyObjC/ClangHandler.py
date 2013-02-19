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

    def traverseNodeHelper_(self, cursor):
        self.processNode_(cursor)
        for c in cursor.get_children():
            self.traverseNodeHelper_(c)

    def traverseNode_(self, cursor):
        if (cursor.location.file is not None and cursor.location.file.name.startswith("/Users/kennyskaggs/Projects/Utilities/CodeMap")):

            self.traverseNodeHelper_(cursor)
            

    def processNode_(self, cursor):
        if (cursor.kind.value == 18):
            openClass = GraphNode.alloc().initWithType_andText_andHash_(1, cursor.displayname, cursor.hash)
            self.rootNode.addClass_(openClass)
        elif (cursor.kind.value == 16):
            methodDecl = GraphNode.alloc().initWithType_andText_andHash_(2, cursor.displayname, cursor.hash)
            self.rootNode.addMethod_(methodDecl)
        elif (cursor.kind.value == 104 and cursor.get_definition() is not None):
            methodCall = GraphNode.alloc().initWithType_andText_andHash_(3, 'invoking: ' + cursor.displayname, cursor.get_definition().hash)
            self.rootNode.addMethodCall_(methodCall)

class GraphNode(NSObject):
    
    def initWithType_andText_andHash_(self, value, disp, hash):
        self = super(GraphNode, self).init()
        self.subNodes = []
        self.value = value
        self.disp = disp
        self.hashVal = hash
        self.reference = None
        self.viewPlaceHolder = None
        self.container = None
        self.itemLookupTable = {}
        return self
    
    def appendChild_(self, child):
        self.subNodes.append(child)
        child.setParent_(self)
    
    def getChildren(self):
        return self.subNodes

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
        return self.itemLookupTable[key]
    
    def setTarget_(self, target):
        self.reference = target

    def getTarget(self):
        return self.reference
    
    def setParent_(self, parent):
        self.container = parent

    def getParent(self):
        return self.container

class RootNode(GraphNode):

    def init(self):
        self = super(RootNode, self).initWithType_andText_andHash_(0, 'root', 0)
        self.recentClass = None
        self.recentMethod = None
        return self

    def lastClass(self):
        return self.recentClass

    def addClass_(self, classObj):
        self.recentClass = classObj
        self.appendChild_(classObj)

    def lastMethod(self):
        return self.recentMethod

    def addMethod_(self, methodObj):
        if (self.recentClass is not None):
            self.recentMethod = methodObj
            self.recentClass.appendChild_(methodObj)

            self.recentClass.setObject_ForKey_(methodObj, methodObj.getHash())

    def addMethodCall_(self, methodCallObj):
        if (self.recentMethod is not None):
            self.recentMethod.appendChild_(methodCallObj)