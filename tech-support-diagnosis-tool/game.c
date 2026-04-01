#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include "lab4.h"

extern Node      *g_root;
extern EditStack  g_undo;
extern EditStack  g_redo;
extern Hash       g_index;

/* ----------------------------------------------------------------
 * TODO 31  run_diagnosis
 *
 * Walk the decision tree iteratively (no recursion) using a
 * FrameStack.  At each question node ask the user yes/no and push
 * the appropriate child.  At each solution leaf display the fix and
 * ask whether it solved the problem.
 *
 * If the fix did not help, enter the learning phase:
 * - Ask the user what would actually fix the problem.
 * - Ask for a yes/no question that distinguishes their problem
 * from the solution just shown.
 * - Ask which answer applies to their problem.
 * - Create a new question node and a new solution node, wire them
 * correctly, graft them into the tree, record an Edit for
 * undo/redo, and index the new question with canonicalize/h_put.
 *
 * Edge case: if parent is NULL the root itself must be replaced.
 * ---------------------------------------------------------------- */
void run_diagnosis(void) {
    clear();
    attron(COLOR_PAIR(5) | A_BOLD);
    mvprintw(0, 0, "%-80s", " Tech Support Diagnosis");
    attroff(COLOR_PAIR(5) | A_BOLD);

    mvprintw(2, 2, "I'll help diagnose your tech problem.");
    mvprintw(3, 2, "Answer each question with y or n.");
    mvprintw(4, 2, "Press any key to start...");
    refresh();
    getch();

    FrameStack stack;
    fs_init(&stack);

    Node *curr = g_root;
    int y_pos = 2;

    while (curr != NULL) {
        clear();
        y_pos = 2;

        if (curr->isQuestion) {
            /* 1. It's a question node */
            int answer = get_yes_no(y_pos, 2, curr->text);
            
            /* Push to stack so we know our parent if we need to learn */
            fs_push(&stack, curr, answer);

            if (answer == 1) {
                curr = curr->yes;
            } else {
                curr = curr->no;
            }
        } else {
            /* 2. It's a solution node */
            char prompt[256];
            snprintf(prompt, sizeof(prompt), "Suggested fix: %s\n  Did this solve your problem?", curr->text);
            
            int solved = get_yes_no(y_pos, 2, prompt);

            if (solved == 1) {
                mvprintw(y_pos + 4, 2, "Great! Glad I could help. Press any key to return...");
                refresh();
                getch();
                break;
            } else {
                /* 3. Learning Phase */
                clear();
                mvprintw(2, 2, "I need to learn about this problem.");
                
                /* MUST strdup because get_input reuses a static buffer */
                char *new_fix = strdup(get_input(4, 2, "What would actually fix this problem?"));
                
                char q_prompt[256];
                snprintf(q_prompt, sizeof(q_prompt), "Give me a yes/no question that distinguishes your problem\n  from: \"%s\"", curr->text);
                char *new_q_text = strdup(get_input(7, 2, q_prompt));
                
                int answer_for_new = get_yes_no(11, 2, "For your problem, is the answer yes or no?");

                /* Create the new nodes */
                Node *new_leaf = create_solution_node(new_fix);
                Node *new_question = create_question_node(new_q_text);

                /* Wire the new question node */
                if (answer_for_new == 1) {
                    new_question->yes = new_leaf;
                    new_question->no = curr;
                } else {
                    new_question->no = new_leaf;
                    new_question->yes = curr;
                }

                /* Graft into the tree using the parent from the stack */
                Node *parent = NULL;
                int wasYesChild = -1;

                if (fs_empty(&stack)) {
                    /* Edge case: Replaced the root node */
                    g_root = new_question;
                } else {
                    Frame parent_frame = fs_pop(&stack);
                    parent = parent_frame.node;
                    wasYesChild = parent_frame.answeredYes;

                    if (wasYesChild == 1) {
                        parent->yes = new_question;
                    } else {
                        parent->no = new_question;
                    }
                }

                /* Record the edit for Undo/Redo */
                Edit e;
                e.type = EDIT_INSERT_SPLIT;
                e.parent = parent;
                e.wasYesChild = wasYesChild;
                e.oldLeaf = curr;
                e.newQuestion = new_question;
                e.newLeaf = new_leaf;
                
                es_push(&g_undo, e);
                es_clear(&g_redo); /* Clear redo stack when a new edit is made */

                /* Index the new question for the Hash Table */
                char *canon = canonicalize(new_q_text);
                h_put(&g_index, canon, 0); /* 0 is a dummy ID as we just need it indexed */
                free(canon); /* Prevent the memory leak! */

                /* Cleanup temp input strings */
                free(new_fix);
                free(new_q_text);

                mvprintw(15, 2, "Thanks! I'll remember that. Press any key to return...");
                refresh();
                getch();
                break;
            }
        }
    }

    fs_free(&stack);
}

/* ----------------------------------------------------------------
 * TODO 32  undo_last_edit
 * Return 1 on success, 0 if the undo stack is empty.
 * ---------------------------------------------------------------- */
int undo_last_edit(void) {
    if (es_empty(&g_undo)) {
        return 0;
    }

    Edit e = es_pop(&g_undo);

    /* Disconnect the new question and restore the old leaf */
    if (e.parent == NULL) {
        g_root = e.oldLeaf;
    } else {
        if (e.wasYesChild == 1) {
            e.parent->yes = e.oldLeaf;
        } else {
            e.parent->no = e.oldLeaf;
        }
    }

    /* Push this action to the redo stack */
    es_push(&g_redo, e);

    return 1;
}

/* ----------------------------------------------------------------
 * TODO 33  redo_last_edit
 * Return 1 on success, 0 if the redo stack is empty.
 * ---------------------------------------------------------------- */
int redo_last_edit(void) {
    if (es_empty(&g_redo)) {
        return 0;
    }

    Edit e = es_pop(&g_redo);

    /* Disconnect the old leaf and restore the new question structure */
    if (e.parent == NULL) {
        g_root = e.newQuestion;
    } else {
        if (e.wasYesChild == 1) {
            e.parent->yes = e.newQuestion;
        } else {
            e.parent->no = e.newQuestion;
        }
    }

    /* Push this action back to the undo stack */
    es_push(&g_undo, e);

    return 1;
}