#ifndef __COLLECTION_H
#define __COLLECTION_H

template <class Type>
class Collection {
    
public:
    Collection();
    
    int itemCount();
    Type* itemAtIndex(int i);
    
    void addItem(const Type &item);
    
protected:
    class itemType;
    
    int numItems;
    
    Type *array;
    int currentArraySize;
};

#endif