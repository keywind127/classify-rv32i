.globl multiply
multiply:
    # a0: val_1 (multiplicand)
    # a1: val_2 (multiplier)
    # Result will be stored in a0

    mv t0, a0                  # t0 = val_1 (multiplicand)
    li a0, 0                   # a0 = 0 (initialize result to 0)

multiply_loop:
    beq a1, x0, multiply_loop_end   # if a1 (multiplier) == 0, end loop
    andi t1, a1, 1                  # t1 = a1 & 1 (check if LSB of multiplier is set)
    beq t1, x0, multiply_skip_add   # if LSB is 0, skip addition

    add a0, a0, t0                  # a0 = a0 + t0 (add shifted multiplicand to result)

multiply_skip_add:
    slli t0, t0, 1                  # t0 = t0 << 1 (shift multiplicand left by 1)
    srli a1, a1, 1                  # a1 = a1 >> 1 (shift multiplier right by 1)
    j multiply_loop                 # repeat loop

multiply_loop_end:
    jr ra                           # return control to caller


# .text
# multiply:
#     # a0: val_1
#     # a1: val_2                     # a1 = val_2
#     add t0, x0, a0                  # t0 = val_1
#     add a0, x0, x0                  # a0 = val_3 = 0
#     add t1, x0, x0                  # t1 = cnt = 0
# multiply_loop:
#     beq a1, x0, multiply_loop_end   # terminate loop if a1 = 0; val_2 = 0
#     andi t2, a1, 0x1                # t2 = LSB(a1) = LSB(val_2) = a1 & 1 = val_2 & 1
#     beq t2, x0, multiply_loop_skip  # skip adding to t0 if t2 = LSB(val_2) = 0
#     sll t2, t0, t1                  # t2 = t0 << t1 = val_1 << cnt
#     add a0, a0, t2                  # a0 = a0 + val_1 << cnt = val_3 + val_1 << cnt
# multiply_loop_skip:
#     addi t1, t1, 1                  # t1 = t1 + 1; cnt = cnt + 1
#     srli a1, a1, 1                  # a1 = a1 >> 1; val_2 = val_2 >> 1
#     j multiply_loop                 # continue loop
# multiply_loop_end:
#     jr ra                           # return control to caller

# multiply:
#     # a0: val_1
#     # a1: val_2                     # a1 = val_2

#     addi sp, sp, -12
#     sw s0, 0(sp)
#     sw s1, 4(sp)
#     sw s2, 8(sp)

#     add s0, x0, a0                  # s0 = val_1
#     add a0, x0, x0                  # a0 = val_3 = 0
#     add s1, x0, x0                  # s1 = cnt = 0
# multiply_loop:
#     beq a1, x0, multiply_loop_end   # terminate loop if a1 = 0; val_2 = 0
#     andi s2, a1, 0x1                # s2 = LSB(a1) = LSB(val_2) = a1 & 1 = val_2 & 1
#     beq s2, x0, multiply_loop_skip  # skip adding to s0 if s2 = LSB(val_2) = 0
#     sll s2, s0, s1                  # s2 = s0 << s1 = val_1 << cnt
#     add a0, a0, s2                  # a0 = a0 + val_1 << cnt = val_3 + val_1 << cnt
# multiply_loop_skip:
#     addi s1, s1, 1                  # s1 = s1 + 1; cnt = cnt + 1
#     srli a1, a1, 1                  # a1 = a1 >> 1; val_2 = val_2 >> 1
#     j multiply_loop                 # continue loop
# multiply_loop_end:

#     lw s0, 0(sp)
#     lw s1, 4(sp)
#     lw s2, 8(sp)
#     addi sp, sp, 12

#     jr ra                           # return control to caller
