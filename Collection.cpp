#include "Collection.h"

template <class Type>
Collection<Type>::Collection() { }


template <class Type>
int Collection<Type>::itemCount() {
    return this->vec.size();
}

template <class Type>
Type* Collection<Type>::itemAtIndex(int i) {
    return this->vec[i];
}


template <class Type>
void Collection<Type>::addItem(Type *item) {
    this->vec.push_back(item);
}


#include "ClassGraphic.h"
template class Collection<ClassGraphic>;

#include "MethodObject.h"
template class Collection<MethodObject>;
