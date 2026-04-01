#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "lab4.h"

extern Node *g_root;

#define MAGIC   0x54454348u   /* "TECH" */
#define VERSION 1u

typedef struct { Node *node; int id; } NodeMapping;

/* ----------------------------------------------------------------
 * TODO 27  save_tree
 *
 * Serialize the entire tree to a binary file using BFS order.
 *
 * File format:
 * Header:  uint32 magic | uint32 version | uint32 nodeCount
 * Per node (BFS order):
 * uint8  isQuestion
 * uint32 textLen          (bytes, no null terminator in file)
 * char[] text             (exactly textLen bytes)
 * int32  yesId            (-1 if NULL)
 * int32  noId             (-1 if NULL)
 *
 * Return 1 on success, 0 on failure.
 * ---------------------------------------------------------------- */

int save_tree(const char *filename) {
    if (!filename) return 0;
    
    FILE *f = fopen(filename, "wb");
    if (!f) return 0;

    uint32_t magic = MAGIC;
    uint32_t version = VERSION;
    uint32_t nodeCount = g_root ? count_nodes(g_root) : 0;

    /* Write Header */
    if (fwrite(&magic, sizeof(uint32_t), 1, f) != 1 ||
        fwrite(&version, sizeof(uint32_t), 1, f) != 1 ||
        fwrite(&nodeCount, sizeof(uint32_t), 1, f) != 1) {
        fclose(f);
        return 0;
    }

    /* If tree is empty, we are done after writing header */
    if (nodeCount == 0) {
        fclose(f);
        return 1;
    }

    Queue q;
    q_init(&q);

    /* Enqueue root with ID 0. Next IDs start at 1. */
    int32_t next_id = 1;
    q_enqueue(&q, g_root, 0);

    int success = 1;
    while (!q_empty(&q)) {
        Node *curr = NULL;
        int curr_id = 0;
        q_dequeue(&q, &curr, &curr_id);

        uint8_t isQuestion = (uint8_t)curr->isQuestion;
        uint32_t textLen = (uint32_t)strlen(curr->text);

        /* Write node basic data */
        if (fwrite(&isQuestion, sizeof(uint8_t), 1, f) != 1 ||
            fwrite(&textLen, sizeof(uint32_t), 1, f) != 1 ||
            fwrite(curr->text, 1, textLen, f) != textLen) {
            success = 0;
            break;
        }

        int32_t yesId = -1;
        int32_t noId = -1;

        if (curr->yes) {
            yesId = next_id++;
            q_enqueue(&q, curr->yes, yesId);
        }
        if (curr->no) {
            noId = next_id++;
            q_enqueue(&q, curr->no, noId);
        }

        /* Write children IDs */
        if (fwrite(&yesId, sizeof(int32_t), 1, f) != 1 ||
            fwrite(&noId, sizeof(int32_t), 1, f) != 1) {
            success = 0;
            break;
        }
    }

    q_free(&q);
    fclose(f);
    
    return success;
}

/* ----------------------------------------------------------------
 * TODO 28  load_tree
 *
 * Read a file written by save_tree and reconstruct the tree.
 * Validate the magic number.  Read all nodes into a flat array
 * first, then link children in a second pass.
 * Free any existing g_root before installing the new one.
 * Return 1 on success, 0 on any error (free partial allocations).
 * ---------------------------------------------------------------- */
int load_tree(const char *filename) {
    if (!filename) return 0;
    
    FILE *f = fopen(filename, "rb");
    if (!f) return 0;

    uint32_t magic, version, nodeCount;
    
    /* Read Header */
    if (fread(&magic, sizeof(uint32_t), 1, f) != 1 ||
        fread(&version, sizeof(uint32_t), 1, f) != 1 ||
        fread(&nodeCount, sizeof(uint32_t), 1, f) != 1) {
        fclose(f);
        return 0;
    }

    /* Validate Header */
    if (magic != MAGIC || version != VERSION) {
        fclose(f);
        return 0;
    }

    /* Handle empty tree */
    if (nodeCount == 0) {
        if (g_root) free_tree(g_root);
        g_root = NULL;
        fclose(f);
        return 1;
    }

    /* Allocate parallel arrays for Pass 1 (reading flat data) */
    Node **nodes = (Node **)malloc(nodeCount * sizeof(Node*));
    int32_t *yes_ids = (int32_t *)malloc(nodeCount * sizeof(int32_t));
    int32_t *no_ids = (int32_t *)malloc(nodeCount * sizeof(int32_t));

    if (!nodes || !yes_ids || !no_ids) {
        if (nodes) free(nodes);
        if (yes_ids) free(yes_ids);
        if (no_ids) free(no_ids);
        fclose(f);
        return 0;
    }

    /* Initialize nodes array to NULL for safe cleanup on error */
    for (uint32_t i = 0; i < nodeCount; i++) {
        nodes[i] = NULL;
    }

    int success = 1;

    /* PASS 1: Read all nodes and allocate memory */
    for (uint32_t i = 0; i < nodeCount; i++) {
        uint8_t isQuestion;
        uint32_t textLen;
        int32_t yesId, noId;

        if (fread(&isQuestion, sizeof(uint8_t), 1, f) != 1 ||
            fread(&textLen, sizeof(uint32_t), 1, f) != 1) {
            success = 0;
            break;
        }

        nodes[i] = (Node *)malloc(sizeof(Node));
        if (!nodes[i]) {
            success = 0;
            break;
        }
        
        nodes[i]->isQuestion = isQuestion;
        nodes[i]->yes = NULL;
        nodes[i]->no = NULL;
        
        nodes[i]->text = (char *)malloc(textLen + 1);
        if (!nodes[i]->text) {
            free(nodes[i]);
            nodes[i] = NULL;
            success = 0;
            break;
        }

        if (fread(nodes[i]->text, 1, textLen, f) != textLen) {
            success = 0;
            break;
        }
        /* CRITICAL: Manually null-terminate the string */
        nodes[i]->text[textLen] = '\0'; 

        if (fread(&yesId, sizeof(int32_t), 1, f) != 1 ||
            fread(&noId, sizeof(int32_t), 1, f) != 1) {
            success = 0;
            break;
        }
        
        yes_ids[i] = yesId;
        no_ids[i] = noId;
    }

    /* PASS 2: Link children if read was entirely successful */
    if (success) {
        for (uint32_t i = 0; i < nodeCount; i++) {
            if (yes_ids[i] != -1 && (uint32_t)yes_ids[i] < nodeCount) {
                nodes[i]->yes = nodes[yes_ids[i]];
            }
            if (no_ids[i] != -1 && (uint32_t)no_ids[i] < nodeCount) {
                nodes[i]->no = nodes[no_ids[i]];
            }
        }

        /* Swap in the new tree safely */
        if (g_root) {
            free_tree(g_root);
        }
        g_root = nodes[0];
        
    } else {
        /* ERROR CLEANUP: Free all partially allocated nodes to avoid leaks */
        for (uint32_t i = 0; i < nodeCount; i++) {
            if (nodes[i]) {
                if (nodes[i]->text) free(nodes[i]->text);
                free(nodes[i]);
            }
        }
    }

    /* Cleanup temporary arrays and file pointer */
    free(nodes);
    free(yes_ids);
    free(no_ids);
    fclose(f);

    return success;
}