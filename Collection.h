#ifndef __COLLECTION_H
#define __COLLECTION_H

#include <vector>

template <class Type>
class Collection {
    
public:
    Collection();
    
    int itemCount();
    Type* itemAtIndex(int i);
    
    void addItem(Type *item);
    
protected:
    std::vector<Type *>vec;
};

#endif
