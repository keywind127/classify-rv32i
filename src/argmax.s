.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)                     # t0 = max_val = array[0]

    li t1, 0                         # t1 = max_idx = 0
    li t2, 1                         # t2 = index = 1
loop_start:
    beq t2, a1, loop_argmax_end      # terminate loop if t2 == a1; index == array_size
    slli t3, t2, 2                   # t3 = t2 << 2 = t2 * 4
    add t3, a0, t3                   # t3 = &array + t3 = &array + t2 * 4
    lw t3, 0(t3)                     # t3 = array[index]
    blt t3, t0, loop_argmax_swap_end # skip update if array[index] < max_val
    add t0, x0, t3                   # t0 = max_val = array[index] = cur_val
    add t1, x0, t2                   # t1 = max_idx = index = t2
loop_argmax_swap_end:
    addi t2, t2, 1                   # t2 = t2 + 1; index = index + 1
    j loop_start

loop_argmax_end:
    add a0, x0, t1                  # a0 = t1 = max_idx
    jr ra

handle_error:
    li a0, 36
    j exit
