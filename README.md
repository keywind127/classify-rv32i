# Assignment 2: Classify
## 1. Mathematical Functions
In this section, we implement several fundamental functions for use in a [deep learning](https://en.wikipedia.org/wiki/Deep_learning) framework. The implementation must conform to the [RISC-V](https://en.wikipedia.org/wiki/RISC-V) calling convention as outlined in the assignment specifications. Furthermore, only instructions from the [RV32I](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) base instruction set are permitted, precluding the use of any extended instruction sets. As a result, the `mul` instruction must be manually implemented using [RV32I](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) instructions.
### 1.1 Absolute of Integer: `abs`
We are tasked with completing a function that computes the [absolute value](https://en.wikipedia.org/wiki/Absolute_value) of an [integer](https://en.wikipedia.org/wiki/Integer) [in-place](https://en.wikipedia.org/wiki/In-place_algorithm) when provided with the [memory address](https://en.wikipedia.org/wiki/Memory_address) of the [integer](https://en.wikipedia.org/wiki/Integer).

<center>
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Absolute_value.svg/360px-Absolute_value.svg.png" height="200"/>
</center>

The function code is listed below.

```asm=
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0 0(a0)
    bge t0, zero, done

    # TODO: Add your own implementation

done:
    # Epilogue
    jr ra
```
The function begins by loading the [integer](https://en.wikipedia.org/wiki/Integer) from memory and performing a comparison to determine whether the value is [non-negative](https://en.wikipedia.org/wiki/Negative_number). For [non-negative numbers](https://en.wikipedia.org/wiki/Negative_number), the function returns the value as is. For negative numbers, the [sign](https://en.wikipedia.org/wiki/Sign_(mathematics)) can be negated using either the `neg` or `sub` instruction. The completed function is provided below.
```asm=
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0 0(a0)
    bge t0, zero, done

    sub t0, x0, t0      # t0 = -index
    sw t0, 0(a0)        # *addr = -index

done:
    # Epilogue
    jr ra
```
### 1.2 ReLU Activation Function: `relu`
The [ReLU (Rectified Linear Unit) function](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) is a widely-used [activation function](https://en.wikipedia.org/wiki/Activation_function) in [deep learning](https://en.wikipedia.org/wiki/Deep_learning) models, complementing other functions like `tanh` and `sigmoid` to introduce [non-linear discrimination](https://en.wikipedia.org/wiki/Linear_discriminant_analysis). Despite its significance, the principle behind [ReLU](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) is quite straightforward, as illustrated by the formula in the image below.

<center>
<img src="https://machinelearningmastery.com/wp-content/uploads/2018/10/Line-Plot-of-Rectified-Linear-Activation-for-Negative-and-Positive-Inputs.png" height="300"/>
</center>

As shown, negative values are replaced with zeros, while non-negative values remain unchanged. The task requires us to complete the function that implements this behavior.

```asm=
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

loop_start:
    # TODO: Add your own implementation

error:
    li a0, 36          
    j exit   
```

Given an array, each value must be processed using the [ReLU function](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)). In the provided function, the `t1` register is pre-initialized to 0, likely indicating its intended use as an index counter.

The simplest approach involves iterating through each value in the array, checking if it is greater than zero, and, if not, overwriting it with zero at its [memory location](https://en.wikipedia.org/wiki/Memory_address). Below is a naive implementation of this approach.

```asm=
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
```

Several performance [optimization](https://en.wikipedia.org/wiki/Program_optimization) techniques can be applied to improve the function's efficiency. One such enhancement involves incrementing the index by 4 in each iteration, rather than performing a [logical shift](https://en.wikipedia.org/wiki/Logical_shift) for every step. This adjustment eliminates unnecessary computational [overhead](https://en.wikipedia.org/wiki/Overhead_(computing)) and simplifies the indexing process.

The [optimized](https://en.wikipedia.org/wiki/Program_optimization) code is provided below.

```asm=
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0

    slli t2, a1, 2                      # t2 = a1 * 4 = arr_size * 4

loop_start:
    beq t1, t2, relu_loop_end           # terminate loop if t1 == t2; index == 4 * array_size
    add t0, a0, t1                      # t1 = &array + index * 4
    lw t3, 0(t0)                        # t3 = array[index]
    bgt t3, x0, after_relu_loop_swap    # skip update if greater than zero
    sw x0, 0(t0)                        # array[t1] = 0
after_relu_loop_swap:
    addi t1, t1, 4                      # t1 = t1 + 4; index = index + 4
    j loop_start                        # continue loop

relu_loop_end:
    jr ra                               # return control to caller

error:
    li a0, 36
    j exit

```

### 1.3 Maximum Value Index: `argmax`

The [argmax function](https://en.wikipedia.org/wiki/Arg_max) is commonly used in conjunction with the [softmax function](https://en.wikipedia.org/wiki/Softmax_function) at the output layer of a [neural network model](https://en.wikipedia.org/wiki/Neural_network_(machine_learning)). It identifies the index of the highest [probability value](https://en.wikipedia.org/wiki/Probability_distribution). For instance, in [MNIST](https://en.wikipedia.org/wiki/MNIST_database) classification, the output is an array of size 10, where each index represents the probability of the corresponding digit (0–9).

```asm=
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1
loop_start:
    # TODO: Add your own implementation

handle_error:
    li a0, 36
    j exit
```

The function begins with `t0` storing the maximum value observed so far (initially the value at index 0) and `t1` holding the index of this maximum value. Meanwhile, `t2` is initialized to 1, representing the current index for iteration, as the first entry has already been processed.

To complete the function, we iterate through the array, incrementing the index in `t2` with each step. At each iteration, the current value is compared against the stored maximum value. If a larger value is found, both the maximum value and its corresponding index are updated accordingly. The following code demonstrates this approach.

```asm=
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
```

### 1.4 Dot Product: `dot`

The [dot product function](https://en.wikipedia.org/wiki/Dot_product) is a key operation in [matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication), which is extensively utilized in the [fully-connected layers](https://en.wikipedia.org/wiki/Layer_(deep_learning)) of an [MLP (Multi-Layer Perceptron)](https://en.wikipedia.org/wiki/Multilayer_perceptron) network during [forward propagation](https://en.wikipedia.org/wiki/Feedforward_neural_network).

In this task, the function is provided with several arguments: the [addresses](https://en.wikipedia.org/wiki/Memory_address) of two flattened arrays (derived from matrices A and B), the number of element pairs to process, and a skip value. The skip value is particularly important when processing matrix B, as it specifies the step size needed to jump to the next row instead of the next column. This flexibility is essential for generalizing the operation to different matrix shapes.

```asm=
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0            
    li t1, 0         

loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation

loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
```

To implement the function, we iterate through the two flattened arrays using their respective jump intervals. At each step, the corresponding elements are multiplied, and the results are accumulated to compute the [dot product](https://en.wikipedia.org/wiki/Dot_product). The final sum is then returned. Below is the implementation of this function using the `mul` instruction.

```asm=
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
```

Since the `mul` instruction is not included in the [RV32I](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) base set, its use is prohibited. Instead, we have implemented a custom function named `multiply`, which performs integer multiplication. This function accepts two arguments in [registers](https://en.wikipedia.org/wiki/Processor_register) `a0` and `a1` and returns the result in `a0`.

To utilize this function, the values to be multiplied are first moved into [registers](https://en.wikipedia.org/wiki/Processor_register) `a0` and `a1`, and the result is retrieved from `a0` after the function call. However, it is crucial to adhere to the [RISC-V](https://en.wikipedia.org/wiki/RISC-V) calling conventions. This requires saving the values of temporary [registers](https://en.wikipedia.org/wiki/Processor_register) onto the [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) before modifying the [program counter](https://en.wikipedia.org/wiki/Program_counter) to invoke the `multiply` function.

<center>
<img src="https://miro.medium.com/v2/resize:fit:1400/1*lajbRL4RqNfMLVi0qkFPiw.jpeg" height="400"/>
</center>

The following code demonstrates the revised implementation, which complies with both the [RISC-V](https://en.wikipedia.org/wiki/RISC-V) calling conventions and the guidelines specified in Assignment 2 by the course instructor.

```asm=
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
```

### 1.5 Matrix Multiplication: `matmul`

This function performs [matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication), storing the resulting matrix in a third matrix. In the provided source code, the inner and outer loops of the [matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication) operation require completion. 

```asm=
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a6 # incrementing result matrix pointer
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop 
    
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation

error:
    li a0, 38
    j exit
```

Several considerations must be addressed in this function:

- **Epilogue Handling**
    - At the end of the function, [register values](https://en.wikipedia.org/wiki/Processor_register) need to be restored from the [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)). Additionally, the [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) pointer must be reset by 28 [bytes](https://en.wikipedia.org/wiki/Byte), as seven words were stored on the [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) during the prologue.
- **Register Updates**
    - The `s0` register, which tracks the current outer index, must be incremented by 1 to advance to the next row of the result matrix.
    - The `s3` register, which serves as a pointer to the current position in matrix A, must be incremented by the number of columns in matrix A multiplied by 4. This adjustment accounts for the memory layout since [addresses](https://en.wikipedia.org/wiki/Memory_address), not indices, are being manipulated.

The modified code below incorporates these updates and ensures correctness and compliance with the expected functionality.

```asm=
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a6 # incrementing result matrix pointer
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop 
    
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    slli t0, a2, 2
    add s3, s3, t0
    addi s0, s0, 1
    j outer_loop_start

outer_loop_end:

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra

error:
    li a0, 38
    j exit
```

### 1.6 Multiply Integers w/o `mul`

As per the guidelines, the `mul` instruction is not permitted since it is not part of the RV32I base instruction set. However, integer multiplication can be efficiently implemented using [bitwise operations](https://en.wikipedia.org/wiki/Bitwise_operation). This involves [logically shifting](https://en.wikipedia.org/wiki/Logical_shift) the multiplicand and multiplier and conditionally adding the shifted multiplier to the result if the least significant bit ([LSB](https://en.wikipedia.org/wiki/Bit_numbering)) of the multiplicand is 1.

The following code demonstrates the implementation of this multiplication function using this approach.

```asm=
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
```
