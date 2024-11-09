.import multi.s

.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0                    # t0 = accum = 0
    li t1, 0                    # t1 = index = 0

loop_start:
    bge t1, a2, loop_end        # terminate loop if t1 > a2; index > num_elements
    
    mul t2, t1, a3              # t2 = t1 * a3 = index_1 = index * stride_1

    # mv t3, a0
    # mv t4, a1

    # mv a0, t1
    # mv a1, a3
    # jal ra, multiply
    # mv t2, a0

    # mv a0, t3
    # mv a1, t4
    
    slli t2, t2, 2              # t2 = index_1 * 4
    add t2, a0, t2              # t2 = &array_1 + index_1 * 4
    lw t2, 0(t2)                # t2 = array_1[index_1]
    
    mul t3, t1, a4              # t3 = t1 * a4 = index_2 = index * stride_2
    
    slli t3, t3, 2              # t3 = index_2 * 4
    add t3, a1, t3              # t3 = &array_2 + index_2 * 4
    lw t3, 0(t3)                # t3 = array_2[index_2]
    
    mul t2, t2, t3              # t2 = t2 * t3 = array_1[index_1] * array_2[index_2]
    
    add t0, t0, t2              # t0 = t0 + t2; accum += array_1[index_1] * array_2[index_2]
    addi t1, t1, 1              # t1 = t1 + 1; index = index + 1
    j loop_start                # continue loop

loop_end:
    mv a0, t0                   # set accum data
    jr ra                       # return control to caller

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
