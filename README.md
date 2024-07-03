# Pipelined Genetic Algorithm for Optimization

This project involves implementing a pipelined genetic algorithm to optimize complex functions. Genetic algorithms (GAs) are search heuristics that mimic the process of natural selection to generate useful solutions for optimization and search problems.

## Project Description

### Overview of Genetic Algorithm

A genetic algorithm typically includes the following steps:

1. **Initialization**:
    - Generate an initial population randomly.
    - Each individual in the population represents a potential solution to the problem.

2. **Selection**:
    - Evaluate the fitness of each individual.
    - Select individuals based on their fitness to act as parents for the next generation.

3. **Crossover**:
    - Combine pairs of parents to produce offspring.
    - This process involves exchanging portions of their structures to create new individuals.

4. **Mutation**:
    - Introduce random changes to some individuals.
    - This helps maintain genetic diversity within the population.

5. **Fitness Computation**:
    - Evaluate the fitness of the offspring produced by crossover and mutation.

6. **Replacement**:
    - Replace the least fit individuals with the new offspring to form a new generation.
    - Repeat the process until a termination condition is met (e.g., a certain number of generations or a satisfactory fitness level).

### Pipeline Design

The genetic algorithm is implemented using a pipelined architecture to improve efficiency. The pipeline consists of four main stages:

1. **Selection**:
    - The top 3 individuals with the highest fitness are selected for crossover and mutation.
    - The selection process uses a uniform random number generator for diversity.

2. **Crossover & Mutation**:
    - Selected parents undergo crossover to produce new offspring.
    - Mutation introduces changes to some offspring to explore the search space.

3. **Fitness Computation**:
    - Fitness of new offspring is computed.
    - Fitness function: `Fitness = Y + Z + X`
        - `X`: Result of AND operation between input values.
        - `Y`: Result of AND operation between specific bits.
        - `Z`: Result of OR operation between specific bits.

4. **Replacement**:
    - The new offspring replace the least fit individuals in the population.
    - The process continues until the termination condition is met.

### Results

- The pipeline implementation processes 2500 individuals over 20 generations.
- The best fitness achieved in the final generation was 191119.

## Conclusion

This project demonstrates the implementation of a pipelined genetic algorithm for optimization tasks. The pipelined architecture significantly improves the efficiency of the genetic algorithm, enabling it to handle larger populations and more generations effectively.

