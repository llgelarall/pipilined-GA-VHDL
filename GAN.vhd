LIBRARY IEEE;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE type_pkg IS
    TYPE real_t IS ARRAY(NATURAL RANGE <>) OF Real;
    TYPE int_t IS ARRAY(NATURAL RANGE <>) OF INTEGER;
END PACKAGE type_pkg;

USE work.type_pkg.ALL;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;
ENTITY gan IS
    PORT (
        clk : IN STD_LOGIC;
        Number_of_Generations : IN INTEGER := 20;
        Crossover_Probability : IN REAL := 0.9;
        Mutation_Probability : IN REAL := 0.05;
        final_Fitness : OUT REAL;
        done : OUT STD_LOGIC
    );
END gan;

ARCHITECTURE Behavioral OF gan IS
    TYPE arr32in19 IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(18 DOWNTO 0);
    TYPE arr32 IS ARRAY (0 TO 31) OF Real;
    TYPE arr3 IS ARRAY (0 TO 2) OF INTEGER;
    SIGNAL chromosome_mem_init : arr32in19 := ("0011101100001001110", "0010001111001001000", "1100111111110000000", "1101011101111010110", "0001110110110100000", "1000011001101000010", "1100001100000010110", "1100001000010000001", "1100000101100111001", "0100010010011000101", "0100111100101011110", "1101001001100000001", "1110001101010111110", "0111110101011011111", "0001011100001001000", "1011010111000001000", "1000010100010000010", "1101001010100011000", "0101101010100000011", "0010110111000011100", "1011011101101010010", "1101101110011101010", "0010101011011011001", "0100000101001000100", "0101011111000000000", "1010010101100000100", "0000011100101001100", "1001011100011000000", "1001110101100001101", "0110001101100100010", "0011100000011101100", "1101000110101011101");
    SIGNAL fitness_mem_init : arr32 := (1.05556, 1.27778, 1.57778, 1.03333, 1.16667, 1.06667, 1.06667, 1.07778, 0.844444, 0.855556, 0.833333, 1.27778, 0.933333, 0.922222, 1.17778, 1.58889, 1.07778, 1.16667, 1.16667, 1.26667, 1.25556, 1.14444, 0.944444, 1.07778, 1.7, 1.27778, 0.855556, 1.27778, 1.15556, 1.16667, 0.744444, 0.833333);
    SIGNAL chromosome_mem_1_var : arr32in19 := chromosome_mem_init;
    SIGNAL fitness_mem_1_var : arr32 := fitness_mem_init;
    SIGNAL selected_1, selected_2 : INTEGER := 0;
    SIGNAL fitness : REAL := 0.0;
    SIGNAL best_chro_reg, changed_chro : STD_LOGIC_VECTOR(18 DOWNTO 0);
    SIGNAL best_fit_reg : REAL := fitness_mem_init(0);
    SIGNAL selCnt, crossCnt, fitCnt, repCnt, bestCnt : INTEGER := 0;
    SIGNAL crossStart, fitStart, repStart, bestStart : STD_LOGIC := '0';
    -- find 3 greatest number function implementation
    FUNCTION greatest_three(fitness_array : arr32) RETURN arr3 IS
        VARIABLE temp_greatest,temp_second_greatest,temp_third_greatest : REAL;
        VARIABLE temp_greatest_index,temp_second_greatest_index,temp_third_greatest_index : INTEGER := 0;
        VARIABLE outtmp : arr3;
    BEGIN
        temp_greatest := fitness_array(0);
        temp_second_greatest := 0.0;
        temp_third_greatest := 0.0;
        FOR i IN 0 TO 31 LOOP
            IF fitness_array(i) > temp_greatest THEN
                temp_greatest := fitness_array(i);
                temp_greatest_index := i;
                ELSIF fitness_array(i) > temp_second_greatest THEN
                temp_second_greatest := fitness_array(i);
                temp_second_greatest_index := i;
                ELSIF fitness_array(i) >= temp_third_greatest THEN
                temp_third_greatest := fitness_array(i);
                temp_third_greatest_index := i;
            END IF;
        END LOOP;
        outtmp(0) := temp_greatest_index;
        outtmp(1) := temp_second_greatest_index;
        outtmp(2) := temp_third_greatest_index;
        RETURN outtmp;
    END greatest_three;

    FUNCTION findLeast(fitness_array : arr32) RETURN INTEGER IS
        VARIABLE temp_least : REAL;
        VARIABLE temp_least_index : INTEGER := 0;
    BEGIN
        temp_least := fitness_array(0);
        FOR i IN 0 TO 31 LOOP
            IF fitness_array(i) < temp_least THEN
                temp_least := fitness_array(i);
                temp_least_index := i;
            END IF;
        END LOOP;
        RETURN temp_least_index;
    END findLeast;
BEGIN

    -- Selection part --
    selectionStage : PROCESS (clk)
        VARIABLE firtsTmp, secondTmp, thirdTmp : INTEGER := 0;
        VARIABLE greatestTmp : arr3;
        VARIABLE randTmp : REAL;
        VARIABLE seed11, seed12 : POSITIVE := 1;
        VARIABLE seed21, seed22 : POSITIVE := 2;
    BEGIN
        IF selCnt < Number_of_Generations+1 and rising_edge(clk) THEN
            greatestTmp := greatest_three(fitness_mem_1_var);
            UNIFORM(seed11, seed21, randTmp);
            IF (randTmp >= 0.0 AND randTmp < 0.33) THEN
                selected_1 <= greatestTmp(2);
            END IF;
            IF randTmp >= 0.33 AND randTmp < 0.66 THEN
                selected_1 <= greatestTmp(1);
            END IF;
            IF randTmp >= 0.66 AND randTmp <= 1.0 THEN
                selected_1 <= greatestTmp(0);
            END IF;
            UNIFORM(seed21, seed22, randTmp);
            IF (randTmp >= 0.0 AND randTmp < 0.33 AND selected_1 /= greatestTmp(2)) OR (randTmp >= 0.66 AND randTmp <= 1.0 AND selected_1 = greatestTmp(0)) THEN
                selected_2 <= greatestTmp(2);
            END IF;
            IF (randTmp >= 0.33 AND randTmp < 0.66 AND selected_1 /= greatestTmp(1)) OR (randTmp >= 0.0 AND randTmp < 0.33 AND selected_1 = greatestTmp(2)) THEN
                selected_2 <= greatestTmp(1);
            END IF;
            IF (randTmp >= 0.66 AND randTmp <= 1.0 AND selected_1 /= greatestTmp(0)) OR (randTmp >= 0.33 AND randTmp < 0.66 AND selected_1 = greatestTmp(1)) THEN
                selected_2 <= greatestTmp(0);
            END IF;
            crossStart <= '1';
            selCnt <= selCnt + 1; 
        END IF;
    END PROCESS;
    -- CrossOver and Mutation Part --
    crossStage : PROCESS (clk)
        VARIABLE randTmp : REAL;
        VARIABLE crossPoint : INTEGER;
        VARIABLE seed1 : POSITIVE := 1;
        VARIABLE seed2 : POSITIVE := 2;
        VARIABLE arrtmp, arrtmp2 : STD_LOGIC_VECTOR(18 DOWNTO 0);
    BEGIN
        IF  crossCnt < Number_of_Generations+1 and rising_edge(clk) and crossStart='1' THEN
            UNIFORM(seed1, seed2, randTmp);
            crossPoint := INTEGER((randTmp * 18.0)/1.0);
            IF Crossover_Probability >= randTmp THEN
                arrtmp := chromosome_mem_1_var(selected_1);
                arrtmp2 := chromosome_mem_1_var(selected_2);
                arrtmp (crossPoint DOWNTO 0) := arrtmp2(crossPoint DOWNTO 0);
            END IF;
            IF (Mutation_Probability >= randTmp) THEN
                arrtmp(crossPoint) := NOT arrtmp(crossPoint);
            END IF;
            crossCnt <= crossCnt + 1;
            fitStart <= '1';
            changed_chro <= arrtmp;
        END IF;

    END PROCESS;
    -- Fitness Computation Part --
    fitnessStage : PROCESS (clk)
        VARIABLE yCnt, zCnt : REAL := 0.0;
        VARIABLE fitTmp : REAL := 0.0;
        VARIABLE sumTmp : REAL := 0.0;
        VARIABLE y : STD_LOGIC := '1';
    BEGIN
        IF fitCnt < Number_of_Generations+1  and rising_edge(clk) and fitStart = '1' THEN
            FOR i IN 18 DOWNTO 9 LOOP
                IF changed_chro(i) = '1' THEN
                    yCnt := yCnt + 1.0;
                END IF;
                y := y AND changed_chro(i);
            END LOOP;
            fitTmp := yCnt / 10.0;
            FOR i IN 8 DOWNTO 0 LOOP
                IF changed_chro(i) = '0' THEN
                    zCnt := zCnt + 1.0;
                END IF;
            END LOOP;
            IF y = '0' THEN
                zCnt := zCnt + 1.0;
            END IF;
            sumTmp := zCnt / 9.0;
            fitTmp := fitTmp + sumTmp;
            if fitTmp = 2.0 then 
                fitTmp := fitTmp + 1.0;
            end if;
            fitCnt <= fitCnt + 1;
            fitness <= fitTmp;
            repStart <= '1';
            fitTmp := 0.0;
            yCnt := 0.0;
            zCnt := 0.0;
        END IF;
    END PROCESS;
    -- Replacement Part : replace with minimum fitness--
    replacementStage : PROCESS (clk)
        VARIABLE minimum_index : INTEGER;
        VARIABLE chromosome_mem_tmp : arr32in19 := chromosome_mem_1_var;
        VARIABLE fitness_mem_tmp: arr32 := fitness_mem_init;
    BEGIN
        IF repCnt < Number_of_Generations+1 and rising_edge(clk) and repStart = '1' THEN
            chromosome_mem_tmp := chromosome_mem_1_var;
            fitness_mem_tmp := fitness_mem_1_var;
            minimum_index := findLeast(fitness_mem_1_var);
            fitness_mem_tmp (minimum_index) := fitness;
            chromosome_mem_tmp (minimum_index) := changed_chro;
            -- Best Found Register -- 
            IF best_fit_reg < fitness THEN
                best_fit_reg <= fitness;
                best_chro_reg <= changed_chro;
            END IF;
            chromosome_mem_1_var <= chromosome_mem_tmp;
            fitness_mem_1_var <= fitness_mem_tmp;
            repCnt <= repCnt + 1;
        elsif repCnt >= Number_of_Generations+1 then
            done <= '1';
            final_Fitness <= best_fit_reg;
        END IF;
    END PROCESS;
END Behavioral;