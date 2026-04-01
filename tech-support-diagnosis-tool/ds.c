#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "lab4.h"



/* ----------------------------------------------------------------
 * ds.c  --  all data structures for the Tech Support Diagnosis Tool
 *
 * Implement every function marked TODO.  The only functions in this
 * entire lab permitted to use recursion are free_tree and count_nodes.
 * Everything else must be iterative.
 * ---------------------------------------------------------------- */


/* ====== Tree nodes ============================================== */

/* TODO 1 */
Node *create_question_node(const char *question) {
    Node *node = (Node *)malloc(sizeof(Node));
    if (node == NULL) {
        return NULL; 
    }
    
    node->text = strdup(question);
    node->yes = NULL;
    node->no = NULL;
    node->isQuestion = 1; 
    
    return node;
}

/* TODO 2 */
Node *create_solution_node(const char *solution) {
    Node *node = (Node *)malloc(sizeof(Node));
    if (node == NULL) {
        return NULL;
    }
    
    node->text = strdup(solution);
    node->yes = NULL;
    node->no = NULL;
    node->isQuestion = 0; 
    
    return node;
}

/* TODO 3  (recursion allowed) */
void free_tree(Node *node) {
    if (node == NULL) {
        return;
    }
    
    // Post-order traversal: free children first
    free_tree(node->yes);
    free_tree(node->no);
    
    // Free the duplicated string, then the node itself
    free(node->text);
    free(node);
}

/* TODO 4  (recursion allowed) */
int count_nodes(Node *root) {
    if (root == NULL) {
        return 0;
    }
    
    return 1 + count_nodes(root->yes) + count_nodes(root->no);
}


/* ====== FrameStack  (dynamic array, iterative traversal) ======== */

#define INITIAL_CAPACITY 8

/* TODO 5 */
void fs_init(FrameStack *s) {
    if (!s) return;
    s->size = 0;
    s->capacity = INITIAL_CAPACITY;
    s->frames = (Frame *)malloc(s->capacity * sizeof(Frame));
}

/* TODO 6 */
void fs_push(FrameStack *s, Node *node, int answeredYes) {
    if (!s) return;
    
    if (s->size >= s->capacity) {
        int new_capacity = (s->capacity == 0) ? INITIAL_CAPACITY : s->capacity * 2;
        Frame *temp = (Frame *)realloc(s->frames, new_capacity * sizeof(Frame));
        if (temp) {
            s->frames = temp;
            s->capacity = new_capacity;
        } else {
            return; /* realloc failed, handle gracefully by not pushing */
        }
    }
    
    s->frames[s->size].node = node;
    s->frames[s->size].answeredYes = answeredYes;
    s->size++;
}

/* TODO 7 */
Frame fs_pop(FrameStack *s) {
    Frame dummy = {NULL, -1};
    if (!s || s->size == 0) {
        return dummy;
    }
    s->size--;
    return s->frames[s->size];
}

/* TODO 8 */
int fs_empty(FrameStack *s) {
    if (!s) return 1;
    return s->size == 0;
}

/* TODO 9 */
void fs_free(FrameStack *s) {
    if (!s) return;
    free(s->frames);
    s->frames = NULL;
    s->size = 0;
    s->capacity = 0;
}


/* ====== EditStack  (dynamic array, undo/redo) =================== */

/* TODO 10 */
void es_init(EditStack *s) {
    if (!s) return;
    s->size = 0;
    s->capacity = INITIAL_CAPACITY;
    s->edits = (Edit *)malloc(s->capacity * sizeof(Edit));
}

/* TODO 11 */
void es_push(EditStack *s, Edit e) {
    if (!s) return;
    
    if (s->size >= s->capacity) {
        int new_capacity = (s->capacity == 0) ? INITIAL_CAPACITY : s->capacity * 2;
        Edit *temp = (Edit *)realloc(s->edits, new_capacity * sizeof(Edit));
        if (temp) {
            s->edits = temp;
            s->capacity = new_capacity;
        } else {
            return; /* realloc failed */
        }
    }
    
    s->edits[s->size] = e;
    s->size++;
}

/* TODO 12 */
Edit es_pop(EditStack *s) {
    Edit dummy = {0};
    if (!s || s->size == 0) {
        return dummy;
    }
    s->size--;
    return s->edits[s->size];
}

/* TODO 13 */
int es_empty(EditStack *s) {
    if (!s) return 1;
    return s->size == 0;
}

/* TODO 14 */
void es_clear(EditStack *s) {
    if (!s) return;
    s->size = 0; /* Logically clear the stack without freeing the buffer */
}

/* provided -- do not modify */
void es_free(EditStack *s) {
    free(s->edits);
    s->edits    = NULL;
    s->size     = 0;
    s->capacity = 0;
}

void free_edit_stack(EditStack *s) { es_free(s); }


/* ====== Queue  (linked list, BFS) ============================== */

/* TODO 15 */
void q_init(Queue *q) {
    if (!q) return;
    q->front = NULL;
    q->rear = NULL;
    q->size = 0;
}

/* TODO 16 */
void q_enqueue(Queue *q, Node *node, int id) {
    if (!q) return;
    
    QueueNode *qn = (QueueNode *)malloc(sizeof(QueueNode));
    if (!qn) return;
    
    qn->treeNode = node;
    qn->id = id;
    qn->next = NULL;
    
    if (q->rear == NULL) {
        q->front = qn;
        q->rear = qn;
    } else {
        q->rear->next = qn;
        q->rear = qn;
    }
    q->size++;
}

/* TODO 17 */
int q_dequeue(Queue *q, Node **node, int *id) {
    if (!q || q->front == NULL) return 0;
    
    QueueNode *temp = q->front;
    *node = temp->treeNode;
    *id = temp->id;
    
    q->front = q->front->next;
    
    /* CRITICAL: If the queue becomes empty, rear must also be NULL */
    if (q->front == NULL) {
        q->rear = NULL;
    }
    
    free(temp);
    q->size--;
    return 1;
}

/* TODO 18 */
int q_empty(Queue *q) {
    if (!q) return 1;
    return q->size == 0;
}

/* TODO 19 */
void q_free(Queue *q) {
    if (!q) return;
    Node *dummyNode;
    int dummyId;
    while (!q_empty(q)) {
        q_dequeue(q, &dummyNode, &dummyId);
    }
}


/* ====== Hash table  (separate chaining) ======================== */

/* TODO 20 */
char *canonicalize(const char *s) {
    if (s == NULL) return strdup("");
    
    char *canon = (char *)malloc(strlen(s) + 1);
    if (!canon) return NULL;
    
    int j = 0;
    for (int i = 0; s[i] != '\0'; i++) {
        if (isalpha(s[i])) {
            canon[j++] = tolower(s[i]);
        } else if (isspace(s[i])) {
            canon[j++] = '_';
        }
        /* Anything else is dropped by simply not advancing j */
    }
    canon[j] = '\0';
    
    return canon;
}

/* TODO 21  (djb2: hash = hash*33 + c, seed 5381) */
unsigned h_hash(const char *s) {
    unsigned long hash = 5381;
    int c;
    while ((c = *s++)) {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }
    return hash;
}

/* TODO 22 */
void h_init(Hash *h, int nbuckets) {
    if (!h || nbuckets <= 0) return;
    
    h->nbuckets = nbuckets;
    h->size = 0;
    h->buckets = (Entry **)calloc(nbuckets, sizeof(Entry *));
}

/* TODO 23 */
int h_put(Hash *h, const char *key, int solutionId) {
    if (!h || !key) return 0;
    
    unsigned int idx = h_hash(key) % h->nbuckets;
    Entry *curr = h->buckets[idx];
    
    /* Check if key already exists */
    while (curr != NULL) {
        if (strcmp(curr->key, key) == 0) {
            /* Key exists, append solutionId if space allows */
            if (curr->vals.count >= curr->vals.capacity) {
                int new_cap = (curr->vals.capacity == 0) ? 4 : curr->vals.capacity * 2;
                int *temp = (int *)realloc(curr->vals.ids, new_cap * sizeof(int));
                if (!temp) return 0;
                curr->vals.ids = temp;
                curr->vals.capacity = new_cap;
            }
            curr->vals.ids[curr->vals.count++] = solutionId;
            return 1;
        }
        curr = curr->next;
    }
    
    /* Key does not exist, create new Entry */
    Entry *new_entry = (Entry *)malloc(sizeof(Entry));
    if (!new_entry) return 0;
    
    new_entry->key = strdup(key);
    new_entry->vals.capacity = 4;
    new_entry->vals.count = 0;
    new_entry->vals.ids = (int *)malloc(new_entry->vals.capacity * sizeof(int));
    
    if (!new_entry->vals.ids) {
        free(new_entry->key);
        free(new_entry);
        return 0;
    }
    
    new_entry->vals.ids[new_entry->vals.count++] = solutionId;
    
    /* Insert at head of the bucket list */
    new_entry->next = h->buckets[idx];
    h->buckets[idx] = new_entry;
    h->size++;
    
    return 1;
}

/* TODO 24 */
int h_contains(const Hash *h, const char *key, int solutionId) {
    if (!h || !key) return 0;
    
    unsigned int idx = h_hash(key) % h->nbuckets;
    Entry *curr = h->buckets[idx];
    
    while (curr != NULL) {
        if (strcmp(curr->key, key) == 0) {
            for (int i = 0; i < curr->vals.count; i++) {
                if (curr->vals.ids[i] == solutionId) {
                    return 1;
                }
            }
            return 0;
        }
        curr = curr->next;
    }
    return 0;
}

/* TODO 25 */
int *h_get_ids(const Hash *h, const char *key, int *outCount) {
    if (!h || !key || !outCount) {
        if (outCount) *outCount = 0;
        return NULL;
    }
    
    unsigned int idx = h_hash(key) % h->nbuckets;
    Entry *curr = h->buckets[idx];
    
    while (curr != NULL) {
        if (strcmp(curr->key, key) == 0) {
            *outCount = curr->vals.count;
            return curr->vals.ids;
        }
        curr = curr->next;
    }
    
    *outCount = 0;
    return NULL;
}

/* TODO 26 */
void h_free(Hash *h) {
    if (!h || !h->buckets) return;
    
    for (int i = 0; i < h->nbuckets; i++) {
        Entry *curr = h->buckets[i];
        while (curr != NULL) {
            Entry *temp = curr;
            curr = curr->next;
            
            free(temp->key);
            free(temp->vals.ids);
            free(temp);
        }
    }
    
    free(h->buckets);
    h->buckets = NULL;
    h->size = 0;
    h->nbuckets = 0;
}
