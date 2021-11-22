LIBRARY ieee ;
USE ieee.std_logic_1164.ALL;

ENTITY tb_car_parking_system IS
END tb_car_parking_system ;

ARCHITECTURE behavior OF tb_car_parking_system IS

-- Component Declaration for the car parking system in VHDL

COMPONENT car_parking_system IS
PORT(
clock : IN std_logic;
rst : IN std_logic;
sensor : IN std_logic;
front_sensored : IN std_logic;
code_1 : IN std_logic_vector(1 downto 0);
code_2 : IN std_logic_vector(1 downto 0);
passLight : OUT std_logic;
stopLIGHT : OUT std_logic;
hex1 : OUT std_logic_vector(6 downto 0);
hex2 : OUT std_logic_vector(6 downto 0)
);
END COMPONENT;
  

--Inputs
signal clock : std_logic := '0';
signal rst : std_logic := '0';
signal sensor : std_logic := '0';
signal front_sensored : std_logic := '0';
signal code_1 : std_logic_vector(1 downto 0) := (others => '0');
signal code_2 : std_logic_vector(1 downto 0) := (others => '0');

--Outputs
signal passLight : std_logic;
signal stopLIGHT : std_logic;
signal hex1 : std_logic_vector(6 downto 0);
signal hex2 : std_logic_vector(6 downto 0);

-- Clock period definitions
constant timeValue : time := 10 ns;

BEGIN
-- Instantiate the car parking system in VHDL
car_park_system: car_parking_system PORT MAP (
clock => clock,
rst => rst,
sensor => sensor,
front_sensored => front_sensored,
code_1 => code_1,
code_2 => code_2,
passLight => passLight,
stopLIGHT => stopLIGHT,
hex1 => hex1,
hex2 => hex2
);

-- Clock process definitions
clk_process :process
begin
clock <= '0';
wait for timeValue*2; --20ns
clock <= '1';
wait for timeValue*2; --20ns
end process;
-- Stimulus process
stim_proc: process
begin
rst <= '0'; --inliazing everything to 0
sensor <= '0';
front_sensored <= '0';
code_1 <= "00";
code_2 <= "00";
wait for timeValue*15;
rst <= '1';
wait for timeValue*15;
sensor <= '1';
wait for timeValue*15;
code_1 <= "01";
code_2 <= "10";
wait until hex1 = "0000010";
code_1 <= "00";
code_2 <= "00";
front_sensored <= '1';
wait until hex1 = "0010010"; -- stop the next car and require password
code_1 <= "01";
code_2 <= "10";
sensor <= '0';
wait until hex1 = "0000010";
code_1 <= "00";
code_2 <= "00";
front_sensored <= '1';
wait until hex1 = "1111111";
front_sensored <= '0';
wait;
end process;

END;