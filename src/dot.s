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

    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    li s0, 0                    # s0 = accum = 0
    li s1, 0                    # s1 = index = 0
    mv s2, a0
    mv s3, a1
    mv s4, a2
    mv s5, a3
    mv s6, a4

loop_start:
    bge s1, s4, loop_end        # terminate loop if s1 > s4; index > num_elements
    
    #mul t2, s1, s5              # t2 = s1 * s5 = index_1 = index * stride_1

    mv a0, s1
    mv a1, s5
    jal ra, multiply
    mv t2, a0
    
    slli t2, t2, 2              # t2 = index_1 * 4
    add t2, s2, t2              # t2 = &array_1 + index_1 * 4
    lw t2, 0(t2)                # t2 = array_1[index_1]
    
    # mul t3, s1, s6              # t3 = s1 * s6 = index_2 = index * stride_2

    addi sp, sp, -4
    sw t2, 0(sp)

    mv a0, s1
    mv a1, s6
    jal ra, multiply
    mv t3, a0

    lw t2, 0(sp)
    addi sp, sp, 4
    
    slli t3, t3, 2              # t3 = index_2 * 4
    add t3, s3, t3              # t3 = &array_2 + index_2 * 4
    lw t3, 0(t3)                # t3 = array_2[index_2]

    addi sp, sp, -4
    sw t3, 0(sp)
    
    #mul t2, t2, t3              # t2 = t2 * t3 = array_1[index_1] * array_2[index_2]

    mv a0, t2
    mv a1, t3
    jal ra, multiply
    mv t2, a0

    lw t3, 0(sp)
    addi sp, sp, 4
    
    add s0, s0, t2              # s0 = s0 + t2; accum += array_1[index_1] * array_2[index_2]
    addi s1, s1, 1              # s1 = s1 + 1; index = index + 1
    j loop_start                # continue loop

loop_end:
    mv a0, s0                   # set accum data
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    jr ra                       # return control to caller

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
