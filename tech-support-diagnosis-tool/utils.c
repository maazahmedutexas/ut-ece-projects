#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include "lab4.h"

extern Node *g_root;

/* ----------------------------------------------------------------
 * TODO 29  check_integrity
 *
 * Use BFS to verify:
 * - Every question node has both yes and no children (non-NULL).
 * - Every solution node has both children NULL.
 * Return 1 if valid, 0 if any violation is found.
 * ---------------------------------------------------------------- */
int check_integrity(void) {
    if (!g_root) return 1; /* Empty tree is structurally valid */

    Queue q;
    q_init(&q);
    q_enqueue(&q, g_root, 0);

    while (!q_empty(&q)) {
        Node *curr;
        int dummyId;
        q_dequeue(&q, &curr, &dummyId);

        if (curr->isQuestion) {
            if (!curr->yes || !curr->no) {
                q_free(&q);
                return 0; /* Violation: Question missing a branch */
            }
            q_enqueue(&q, curr->yes, 0);
            q_enqueue(&q, curr->no, 0);
        } else {
            if (curr->yes || curr->no) {
                q_free(&q);
                return 0; /* Violation: Solution has a branch */
            }
        }
    }
    
    q_free(&q);
    return 1;
}

/* ----------------------------------------------------------------
 * Helper struct for TODO 30 parent tracking during BFS
 * ---------------------------------------------------------------- */
typedef struct {
    Node *node;
    int parent_idx;
    int branch; /* 1 for YES, 0 for NO, -1 for Root */
} PathNode;

/* ----------------------------------------------------------------
 * TODO 30  find_shortest_path
 *
 * Given the exact text of two solution leaves, display the
 * questions that distinguish them.  Use BFS with a parent-tracking
 * PathNode array to find both leaves, build ancestor arrays for
 * each, find the Lowest Common Ancestor (LCA), then print:
 * - The shared path of questions both solutions pass through.
 * - The divergence question (LCA) and which branch leads where.
 *
 * Display results with mvprintw.  Print an error if either
 * solution is not found.  Free all allocations before returning.
 * ---------------------------------------------------------------- */
void find_shortest_path(const char *sol1, const char *sol2) {
    if (g_root == NULL) {
        mvprintw(10, 2, "Error: knowledge base is empty.");
        refresh();
        return;
    }

    if (strcmp(sol1, sol2) == 0) {
        mvprintw(10, 2, "Error: Solutions are identical.");
        refresh();
        return;
    }

    int total_nodes = count_nodes(g_root);
    PathNode *tracker = (PathNode *)malloc(total_nodes * sizeof(PathNode));
    if (!tracker) return;

    int head = 0, tail = 0;
    int idx1 = -1, idx2 = -1;

    /* Push root to tracker array */
    tracker[tail].node = g_root;
    tracker[tail].parent_idx = -1;
    tracker[tail].branch = -1;
    tail++;

    /* 1. BFS to map out the tree and track parents */
    while (head < tail) {
        int curr_idx = head++;
        Node *curr = tracker[curr_idx].node;

        if (!curr->isQuestion) {
            if (strcmp(curr->text, sol1) == 0) idx1 = curr_idx;
            if (strcmp(curr->text, sol2) == 0) idx2 = curr_idx;
        } else {
            if (curr->yes) {
                tracker[tail].node = curr->yes;
                tracker[tail].parent_idx = curr_idx;
                tracker[tail].branch = 1; /* 1 means YES branch */
                tail++;
            }
            if (curr->no) {
                tracker[tail].node = curr->no;
                tracker[tail].parent_idx = curr_idx;
                tracker[tail].branch = 0; /* 0 means NO branch */
                tail++;
            }
        }
    }

    /* Check if both solutions were actually found */
    if (idx1 == -1 || idx2 == -1) {
        mvprintw(10, 2, "Error: One or both solutions not found in knowledge base.");
        refresh();
        free(tracker);
        return;
    }

    /* 2. Trace backwards from leaves to the root */
    int *path1 = (int *)malloc(total_nodes * sizeof(int));
    int *path2 = (int *)malloc(total_nodes * sizeof(int));
    int len1 = 0, len2 = 0;

    int curr = idx1;
    while (curr != -1) { 
        path1[len1++] = curr; 
        curr = tracker[curr].parent_idx; 
    }
    
    curr = idx2;
    while (curr != -1) { 
        path2[len2++] = curr; 
        curr = tracker[curr].parent_idx; 
    }

    /* Reverse the path arrays so they go Root -> Leaf */
    for (int i = 0; i < len1 / 2; i++) { 
        int t = path1[i]; path1[i] = path1[len1 - 1 - i]; path1[len1 - 1 - i] = t; 
    }
    for (int i = 0; i < len2 / 2; i++) { 
        int t = path2[i]; path2[i] = path2[len2 - 1 - i]; path2[len2 - 1 - i] = t; 
    }

    /* 3. Find the Lowest Common Ancestor (LCA) */
    int lca_depth = 0;
    while (lca_depth < len1 && lca_depth < len2 && path1[lca_depth] == path2[lca_depth]) {
        lca_depth++;
    }
    lca_depth--; /* Step back to the last matching node index */

    /* 4. Display the results to the ncurses screen */
    int row = 10;
    mvprintw(row++, 2, "Shared Diagnostic Path:");
    
    if (lca_depth == 0) {
        mvprintw(row++, 4, "(None. Divergence starts immediately at the root question.)");
    } else {
        for (int i = 0; i < lca_depth; i++) {
            Node *q_node = tracker[path1[i]].node;
            const char *ans = tracker[path1[i+1]].branch ? "YES" : "NO";
            mvprintw(row++, 4, "%s -> %s", q_node->text, ans);
        }
    }

    row++;
    Node *lca_node = tracker[path1[lca_depth]].node;
    mvprintw(row++, 2, "Divergence Question: %s", lca_node->text);
    
    /* Peek ahead one step to see which branch was taken */
    const char *ans1 = tracker[path1[lca_depth + 1]].branch ? "YES" : "NO";
    const char *ans2 = tracker[path2[lca_depth + 1]].branch ? "YES" : "NO";

    mvprintw(row++, 4, "If %s -> leads to: \"%s\"", ans1, sol1);
    mvprintw(row++, 4, "If %s -> leads to: \"%s\"", ans2, sol2);

    refresh();

    /* 5. Memory cleanup */
    free(path1);
    free(path2);
    free(tracker);
}