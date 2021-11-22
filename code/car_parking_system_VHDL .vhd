library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity car_parking_system is
--we had 64 macrocells in EPM7064STC44-10,
--after trial and error we found count should be 16 bits and hex1 and hex2 should br 8 bits each, to keep the total macrocells to 54<64
--value representation correct codes: code 1 = 10 and code 2 = 01 and hex1 <= "00000010" hex2 <= "01000000"
--								while wait hex1 = "00001101" hex2 = "01010101"
--								wrong code hex1 <= "00001101" hex2 <= "00001101"
port
(
 clock,rst: in std_logic; --global clock and reset
 sensor: in std_logic; --sensor which helps when car comes from gate
 code1, code2: in std_logic_vector(1 downto 0); -- 2 bits we need only 01 and 10, for storing input codes
 passLight,stopLight,exitLight: out std_logic;  --self explanatory names, exit light when car has exited
 hex1, hex2: out std_logic_vector(7 downto 0) --the code wont work without two hex values
);
end car_parking_system;

architecture Behavioral of car_parking_system is
type FSM_States is --using finite state machine
(intital,wrongCode1,wrongCode2,correctCode,tempCode,GOTO_EXIT);
signal curr,nxt: FSM_States;
signal stopLight_tmp: std_logic;
signal passLight_tmp: std_logic;
signal exitLight_tmp: std_logic;
signal front_sensored: std_logic;
signal code_1, code_2: std_logic_vector(1 downto 0); 
signal count: std_logic_vector(15 downto 0);

begin
EdgeDetector_ins : entity work.EdgeDetector --tried basic file handling in vhdl
port map(
 clock => clock,
 d => sensor,
 edge => front_sensored
);
process(clock)
begin
if rising_edge(clock) then --rising_edge is basically @posedge
 if (front_sensored = '1') then --sensor signals a car going to gate
  code_1 <= code1; --initializing
  code_2 <= code2;
 end if;
end if;
end process;
process(clock,rst)
begin
if(rst='0') then--at t=0
 curr <= intital;--initializing
elsif(rising_edge(clock)) then
 curr <= nxt;--if @posedge then change current to next
end if;
end process;
process(curr,code_1,code_2,count,front_sensored) 
begin
case curr is
when intital =>
if(front_sensored = '1') then --sensor signals a car going to gate
 nxt <= tempCode;--value is stored in tmp
else
 nxt <= intital; --not changed	
end if;
when tempCode =>
if(count <= x"00000002") then --in this line count for two cycles and code is checked after 3 cycles
 nxt <= tempCode;
else
if((code_1="10")and(code_2="01")) then
nxt <= correctCode; --code is correct let the car in
else
nxt <= wrongCode1; --first wrongcode
end if;
end if;
when wrongCode1 => --second wrong code
 if((code_1="10")and(code_2="01")) then
nxt <= correctCode;--code is correct let the car in
 else
nxt <= wrongCode2;
 end if;
 when wrongCode2 => --third wrong code
 if((code_1="10")and(code_2="01")) then
nxt <= correctCode;--code is correct let the car in
 else
nxt <= GOTO_EXIT; -- after three wrong codes send car straight to exit
 end if;
when GOTO_EXIT =>
 if(count > x"0000000F") then
nxt <= intital;--after exiting the next state is the idle/initial state 
 else
nxt <= nxt;--if car doesnt exit nothing changes
 end if;
when correctCode => nxt <= intital;--car has exited
when others => nxt <= intital; --default like in case statement in c
end case;
end process;
process(clock,rst)
begin
if(rst='0') then
count <= (others => '0');
elsif(rising_edge(clock))then
 if(curr=tempCode)then
 count <= count + x"0001";--increase count by 1
else
 count <= (others => '0');
 end if;
end if;
end process;
process(clock) 
begin
if(rising_edge(clock)) then
case(curr) is
when intital => --idle state only passlight glows
passLight_tmp <= '1';
stopLight_tmp <= '0';
exitLight_tmp <= '0';
hex1 <= "00000000"; 
hex2 <= "00000000"; 
when tempCode =>
passLight_tmp <= '0';--while waiting stop light glows
stopLight_tmp <= '1';
exitLight_tmp <= '0'; 
hex1 <= "00001101"; 
hex2 <= "01010101"; 
when wrongCode1 =>
passLight_tmp <= '0'; 
stopLight_tmp <= '1';--after entering wrong code stop light glows
exitLight_tmp <= '0';
hex1 <= "00001101"; 
hex2 <= "00001101";
when wrongCode2 =>
passLight_tmp <= '0'; 
stopLight_tmp <= '1';--after entering wrong code stop light glows
exitLight_tmp <= '0';
hex1 <= "00001101"; 
hex2 <= "00001101";
when GOTO_EXIT =>
passLight_tmp <= '0'; 
stopLight_tmp <= '1';--after entering wrong code stop light glows
exitLight_tmp <= '1';--car has exited hence exitlight glows
hex1 <= "00001101"; 
hex2 <= "00001101";
when correctCode =>
passLight_tmp <= '1';--code entered is correct hence passlight glows
stopLight_tmp <= '0'; 
exitLight_tmp <= '0';
hex1 <= "00000010"; 
hex2 <= "01000000";  
when others => 
passLight_tmp <= '0';--default
stopLight_tmp <= '0';
exitLight_tmp <= '0';
hex1 <= "00000000"; 
hex2 <= "00000000"; 
 end case;
end if;
end process;
 stopLight <= stopLight_tmp;
 passLight <= passLight_tmp;
end Behavioral;