// ECE 312 - Linked List Lab
// Name: Maaz Ahmed
// EID:  ma69299

#include <stdlib.h>
#include <stdio.h> // Included for NULL
#include "linkedlist.h"

/*
 * Creates a new empty linked list.
 * * Returns: Pointer to the new LinkedList, or NULL on failure
 */
LinkedList* createList(void) {
	LinkedList* list = (LinkedList*)malloc(sizeof(LinkedList));
	if(list == NULL) return NULL;
	list->head = NULL;
	list->size = 0;
	return list;
}

/*
 * Frees all memory associated with the linked list.
 * * Returns: Nothing 
 */
void destroyList(LinkedList* list) {
	if (list == NULL) return;
	Node* current = list->head;
	while(current != NULL){
	Node* temp = current->next;
	free(current);
	current = temp;
}

free(list);

}

/*
 * Inserts a new element at the front (head) of the list.
 * * Returns: 0 on success, -1 on failure
 */
int insertAtHead(LinkedList* list, int value) {
	if (list == NULL) return -1;
	Node* newNode = (Node*)malloc(sizeof(Node));
	if(newNode == NULL) return -1;
	newNode->data = value;
	newNode->next = list->head;
	list->head = newNode;
	list->size++;
	return 0;


}

/*
 * Inserts a new element at the end (tail) of the list.
 * * Returns: 0 on success, -1 on failure
 */
int insertAtTail(LinkedList* list, int value) {
	if(list == NULL) return -1;
	Node* newNode = (Node*)malloc(sizeof(Node));
	if(newNode == NULL) return -1;
	newNode->data = value;
	newNode->next = NULL;
	if(list->head == NULL){
		list->head = newNode;
		list->size++;
		return 0;
	}

	Node* current = list->head;
	while(current->next != NULL) current = current->next;
	current->next = newNode;
	list->size++;
	return 0;
}

/*
 * Inserts a new element at the specified index.
 *
 * Returns: 0 on success, -1 if index invalid or allocation fails
 */
int insertAtIndex(LinkedList* list, int index, int value) {
	if (list == NULL) return -1;
	if(index < 0 || index > list->size) return -1;
	if (index == 0) return insertAtHead(list, value);
	if (index == list->size) return insertAtTail(list, value);

	Node* newNode = (Node*)malloc(sizeof(Node));
	if (newNode == NULL) return -1;
	newNode->data = value;
	Node* current = list->head;
	for(int i = 0; i < index -1; i++){
		current = current->next;
	}
	newNode->next = current->next;
	current->next = newNode;

	list->size++;
	return 0;

}

/*
 * Removes the element at the front (head) of the list.
 *
 * Returns: 0 on success, -1 if list is empty
 */
int removeAtHead(LinkedList* list) {
	if(list == NULL || list->head == NULL) return -1;
	Node* toRemove = list->head;
	list->head = toRemove->next;
	free(toRemove);
	list->size--;
	return 0;

}

/*
 * Removes the element at the specified index.
 * * Returns: 0 on success, -1 if index is out of bounds
 */
int removeAtIndex(LinkedList* list, int index) {
	if(list == NULL) return -1;
	if(index < 0 || index >= list->size) return -1;
	if(index == 0) return removeAtHead(list);
	Node* current = list->head;
	for(int i = 0; i < index - 1; i++){
	current = current->next;
}
	Node* toRemove = current->next;
	current->next = toRemove->next;
	free(toRemove);
	list->size--;
	return 0;
}

/*
 * Retrieves the element at the specified index.
 *
 * Returns: 0 on success, -1 if index out of bounds or NULL pointers
 */
int getElement(LinkedList* list, int index, int* result) {
	if(list == NULL || result == NULL) return -1;
	if (index < 0 || index >= list->size) return -1;
	Node* current = list->head;
	for(int i = 0; i < index; i++){
	current = current->next;
}
	*result = current->data;
	return 0;
}

/*
 * Returns the number of elements in the list.
 *
 * Returns -1 if list is NULL.
 */
int getSize(LinkedList* list) {
	if(list == NULL) return -1;
	return list->size;
}
