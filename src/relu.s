.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

loop_start:
    beq t1, a1, relu_loop_end           # terminate loop if t1 == a1; index == array_size
    slli t0, t1, 2                      # t0 = t1 << 2 = t1 * 4
    add t0, a0, t0                      # t0 = &array + t1 * 4
    lw t3, 0(t0)                        # t3 = array[t1]
    bgt t3, x0, after_relu_loop_swap    # skip update if greater than zero
    sw x0, 0(t0)                        # array[t1] = 0
after_relu_loop_swap:
    addi t1, t1, 1                      # t1 = t1 + 1; index = index + 1
    j loop_start                        # continue loop

relu_loop_end:
    jr ra                               # return control to caller

error:
    li a0, 36
    j exit
