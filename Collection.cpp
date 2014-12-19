#include "Collection.h"

template <class Type>
Collection<Type>::Collection() {
    this->numItems = 0;
    this->currentArraySize = 10;
    
    this->array = new Type[this->currentArraySize];
}


template <class Type>
int Collection<Type>::itemCount() {
    return this->numItems;
}

template <class Type>
Type* Collection<Type>::itemAtIndex(int i) {
    return &(this->array[i]);
}


template <class Type>
void Collection<Type>::addItem(const Type &item) {
    if (this->numItems >= this->currentArraySize) {
        this->currentArraySize *= 2;
        
        Type *newArray = new Type[this->currentArraySize];
        for (int i=0; i<this->numItems; i++) {
            newArray[i] = this->array[i];
        }
        
        delete [] this->array;
        this->array = newArray;
    }
    
    this->array[this->numItems] = item;
    this->numItems += 1;
}


#include "ClassGraphic.h"
template class Collection<ClassGraphic>;