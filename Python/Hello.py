import sys
sys.path.append('/Users/kennyskaggs/Projects/Clang/llvm/tools/clang/bindings/python/')
import clang.cindex

def find_typerefs(node, indent):
    
    print '%s%s [line=%s, col=%s]' % (indent, node.displayname, node.location.line, node.location.column)

    for c in node.get_children():
        findforchildren(c, indent+"\t")
        
def findforchildren(node, indent):
    
    if (node.location.file is not None and node.location.file.name.startswith("/Users/kennyskaggs/Projects/Utilities/CodeMap")):
        
        if (node.is_definition()):
            print 'definition:'
        
        if (node.get_definition() is not None):
            print '%s%s %d decl=%s' % (indent, node.displayname, node.hash, node.get_definition().hash)
        else:
            print '%s%s %d' % (indent, node.displayname, node.hash)
        
        for c in node.get_children():
            findforchildren(c, indent+"\t")

index = clang.cindex.Index.create()
tu = index.parse("/Users/kennyskaggs/Projects/Utilities/CodeMap/CodeMap/CMObjectiveCParser.m")
print 'Translation unit:', tu.spelling
find_typerefs(tu.cursor, "")