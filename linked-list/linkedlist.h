#ifndef LINKEDLIST_H
#define LINKEDLIST_H

// The Node structure
typedef struct Node {
    int data;
    struct Node* next;
} Node;

// The LinkedList structure
typedef struct {
    Node* head;
    int size;
} LinkedList;

// Function Prototypes
LinkedList* createList(void);
void destroyList(LinkedList* list);
int insertAtHead(LinkedList* list, int value);
int insertAtTail(LinkedList* list, int value);
int insertAtIndex(LinkedList* list, int index, int value);
int removeAtHead(LinkedList* list);
int removeAtIndex(LinkedList* list, int index);
int getElement(LinkedList* list, int index, int* result);
int getSize(LinkedList* list);
void printList(LinkedList* list); // Helper for debugging

#endif
