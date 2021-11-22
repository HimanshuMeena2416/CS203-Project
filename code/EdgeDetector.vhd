LIBRARY ieee ;
USE ieee.std_logic_1164.ALL;
entity EdgeDetector is
	port(
		clock: in std_logic;
		d: in std_logic;
		edge: out std_logic
	);
end EdgeDetector;
architecture EdgeDetector_rtl of EdgeDetector is
	signal reg1: std_logic;
	signal reg2: std_logic;
begin
reg: process(clock)
begin
	if rising_edge(clock) then
		reg1 <= d;
		reg2 <= reg1;
	end if;
end process;
edge <= reg1 and (not reg2);
end EdgeDetector_rtl;