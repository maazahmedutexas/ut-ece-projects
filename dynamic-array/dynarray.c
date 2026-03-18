// ECE 312 - Dynamic Array Lab
// Name: Maaz Ahmed
// EID:  ma69299

#include <stdlib.h>
#include "dynarray.h"

/*
 * Creates a new DynamicArray with the specified initial capacity.
 * Returns: Pointer to the new DynamicArray, or NULL on failure
 */
DynamicArray* createArray(int initialCapacity) {
	if(initialCapacity <= 0) return NULL;
	// First we want to allocate space for the struct
	DynamicArray* newArr = (DynamicArray*)malloc(sizeof(DynamicArray));
	if (newArr == NULL) return NULL;
	// now we want to allocate space for integer data array
	newArr->data = (int*)malloc(sizeof(int) * initialCapacity);
	// if the data array fails, we must free the struct to prevent memory leak
	if(newArr->data == NULL){
		free(newArr);
		return NULL;
	}
	// we now want to initialize the variables
	newArr->size = 0;
	newArr->capacity = initialCapacity;
	return newArr;
}


/*
 * Frees all memory associated with the DynamicArray.
 */
void destroyArray(DynamicArray* arr) {
	if(arr == NULL) return;

	if(arr->data != NULL){ // we would want to free the inner array first
		free(arr->data);
	}

	free(arr); // then we free the container struct
}

/*
 * Adds an element to the end of the array.
 * Returns: 0 on success, -1 on failure
 */
int addElement(DynamicArray* arr, int value) {
	if(arr == NULL) return -1;
	// now we want to see if its full right now
	if (arr->size == arr->capacity){
		int newCapacity = arr->capacity *2;
		int* temp = (int*)realloc(arr->data, sizeof(int) * newCapacity); // trying to resize
		// if resize failed, return error, but dont want to break the original array we had
		if(temp == NULL) return -1;

		// success, so we want to update the struct
		arr->data = temp;
		arr->capacity = newCapacity;
	}
	// add element to the end
	arr->data[arr->size] = value;
	arr->size++;
	return 0;
}

/*
 * Retrieves the element at the specified index.
 * Returns: 0 on success, -1 on failure (invalid index or NULL pointers)
 */
int getElement(DynamicArray* arr, int index, int* result) {
	if(arr == NULL || result == NULL) return -1;

	// now we need to check bounds, index cannot be negative or >= to the size
	if (index < 0|| index >= arr->size) return -1;

	// deferefence result to write down the actual value there
	*result = arr->data[index];
	return 0;
}

/*
 * Sets the element at the specified index to the given value.
 * Returns: 0 on success, -1 on failure
 */
int setElement(DynamicArray* arr, int index, int value) {
	if (arr == NULL) return -1;
	if (index < 0 || index >= arr->size) return -1;
	arr->data[index] = value;
	return 0;
}

/*
 * Returns the current number of elements in the array.
 * Returns -1 if arr is NULL.
 */
int getSize(DynamicArray* arr) {
	if(arr == NULL) return -1;
	return arr->size;
}

/*
 * Returns the current capacity of the array.
 * Returns -1 if arr is NULL.
 */
int getCapacity(DynamicArray* arr) {
	if(arr == NULL) return -1;
	return arr->capacity;
}

/*
 * Removes the element at the specified index.
 * Returns: 0 on success, -1 on failure
 */
int removeElement(DynamicArray* arr, int index) {
	if (arr == NULL) return -1;
	if (index < 0 || index >= arr->size) return -1;
	// we want to shift everything left, bc we're taking out an element
	for(int i = index; i < arr->size -1; i++){
		arr->data[i] = arr->data[i+1];
	}
	arr->size--;
	return 0;
}
