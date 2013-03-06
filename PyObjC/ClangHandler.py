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

    def traverseNode_(self, cursor):
        if (cursor.location.file is not None and cursor.location.file.name.startswith("/Users/kennyskaggs/Projects/Utilities/CodeMap")):

            self.processNode_withIndent_InsideContainer_(cursor, '\t', '')
            
    def processNode_withIndent_InsideContainer_(self, cursor, indent, container):
        
        newContainer = container
        nodeChildren = cursor.get_children()
        
        if (cursor.kind.value == 11):
            print '%sinterface: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            newContainer = 'interface'
            openInterface = GraphNode.alloc().initWithType_andText_andHash_('2interface', cursor.displayname, cursor.hash)
            self.rootNode.addClass_(openInterface)
        
        elif (cursor.kind.value == 18):
            print '%sclass imp: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            openClass = GraphNode.alloc().initWithType_andText_andHash_('2implementation', cursor.displayname, cursor.hash)
            self.rootNode.addClass_(openClass)
    
        elif (cursor.kind.value == 14):
            classRef = nodeChildren.next()
            classTypeName = classRef.displayname if classRef.kind.value == 42 else '?'
            
            print '%sproperty named: %s is of type: %s' % (indent, cursor.displayname, classTypeName)
            propertyNode = GraphNode.alloc().initWithType_andText_andHash_(classTypeName, cursor.displayname, cursor.hash)
            self.rootNode.addClassItemDecl_isPublic_(propertyNode, container == 'interface')
            return
                
        elif (cursor.kind.value == 12): #category
            classRef = nodeChildren.next()
            print '%scategory named: %s of class: %s' % (indent, cursor.displayname, classRef.displayname)
            categoryNode = GraphNode.alloc().initWithType_andText_andHash_('category', classRef.displayname, cursor.hash)
            self.rootNode.addClass_(categoryNode)
    
        elif (cursor.kind.value == 16):
            print '%smethod decl: %s hash=%d' % (indent, cursor.displayname, cursor.hash)
            methodDecl = GraphNode.alloc().initWithType_andText_andHash_('1method', cursor.displayname, cursor.hash)
            self.rootNode.addClassItemDecl_isPublic_(methodDecl, container == 'interface')
    
        elif (cursor.kind.value == 104):
            print '%smethod call %s' % (indent, cursor.displayname)
            methodCall = GraphNode.alloc().initWithType_andText_andHash_('2methodcall', cursor.displayname, None)
            self.rootNode.addMethodCall_(methodCall)
                
            try:
                self.processCall_(cursor)
            except StopIteration:
                print 'no children'
                
        if (cursor.get_definition() is not None):
            print '%s%s %d decl=%d kind=%d' % (indent, cursor.displayname, cursor.hash, cursor.get_definition().hash, cursor.kind.value)
        elif (cursor.referenced is not None):
            print '%s%s %d ref=%d kind=%d refkind=%d' % (indent, cursor.displayname, cursor.hash, cursor.referenced.hash, cursor.kind.value, cursor.referenced.kind.value)
        else:
            print '%s%s %d kind=%d' % (indent, cursor.displayname, cursor.hash, cursor.kind.value)

        for c in nodeChildren:
            self.processNode_withIndent_InsideContainer_(c, indent+'\t', newContainer)

    def processCall_(self, call):
        if (call.referenced is not None):
            grandChild = call.get_children().next()
            childTargetsSelf = self.childrenGiveSelfTarget_(grandChild)
        
            targetKeySuffix = 'property' if call.referenced.kind.value == 14 else 'method'
            
            if (not childTargetsSelf):
                self.processCall_(grandChild)
        
            self.rootNode.targetCallWith_isOnSelf_(call.displayname+targetKeySuffix, childTargetsSelf)

    def childrenGiveSelfTarget_(self, child):
        return child.displayname == 'self' and child.kind.value == 100

class GraphNode(NSObject):
    
    def initWithType_andText_andHash_(self, value, disp, hash):
        self = super(GraphNode, self).init()
        self.subNodes = []
        self.declWaiters = {}
        self.value = value
        self.disp = disp
        self.hashVal = hash
        self.referenceList = []
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
    
    def processWaitersFor_(self, target):
        targetKey = target.getTargetingKey()
        if (targetKey in self.declWaiters):
            for waiter in self.declWaiters[targetKey]:
                waiter.appendTarget_(target)
            self.declWaiters[targetKey] = None
    
    def tieNode_ToTarget_(self, node, targetKey):
        decl = self.getObjectForKey_(targetKey)
        if (decl is not None):
            node.appendTarget_(decl)
        else:
            if (targetKey in self.declWaiters):
                self.declWaiters[targetKey].append(node)
            else:
                self.declWaiters[targetKey] = [node]

    def getType(self):
        return self.value
    
    def setType_(self, type):
        self.value = type

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

    def appendTarget_(self, target):
        self.referenceList.append(target)

    def getTargets(self):
        return self.referenceList

    def setParent_(self, parent):
        self.container = parent

    def getParent(self):
        return self.container

    def getPubliclyAccessible(self):
        return self.accessible

    def setPublic_(self, public):
        self.accessible = public

    def getTargetingKey(self):
        targetSuffix = 'method' if (self.getType() == '1method') else 'property'
        return self.getText() + targetSuffix

class RootNode(GraphNode):

    def init(self):
        self = super(RootNode, self).initWithType_andText_andHash_(0, 'root', 0)
        self.recentClass = None
        self.recentMethod = None
        self.recentMethodCall= None
        return self

    def lastClass(self):
        return self.recentClass

    def addClass_(self, classObj):
        self.recentClass = self.getObjectForKey_(classObj.getText())
        
        if (self.recentClass is None):
            self.recentClass = classObj
            self.setObject_ForKey_(classObj, classObj.getText())
            self.appendChild_(classObj)
        else:
            if (classObj.getType() == '2implementation'):
                self.recentClass.setType_(classObj.getType())

    def lastMethod(self):
        return self.recentMethod

    def addClassItemDecl_isPublic_(self, methodObj, public):
        if (self.recentClass is not None):
            self.recentMethod = self.recentClass.getObjectForKey_(methodObj.getTargetingKey())
            
            if (self.recentMethod is None):
                self.recentClass.appendChild_(methodObj)
                self.recentClass.setObject_ForKey_(methodObj, methodObj.getTargetingKey())
                self.recentMethod = methodObj

            if (public):
                methodObj.setPublic_('Yes');

            if (methodObj.getType() == '1method'):
                self.recentClass.processWaitersFor_(methodObj)


    def addMethodCall_(self, methodCallObj):
        if (self.recentMethod is not None):
            self.recentMethodCall = methodCallObj
            self.recentMethod.appendChild_(methodCallObj)

    def targetCallWith_isOnSelf_(self, targetKey, onSelf):
        if (not onSelf):
            self.recentMethodCall.appendTarget_(targetKey)
        else:
            self.recentClass.tieNode_ToTarget_(self.recentMethodCall, targetKey)

