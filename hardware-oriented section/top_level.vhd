LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY TOP_LEVEL is
	port(rst,clk: in std_logic;
	     V_s: in matrix(1 to No_Vk, 1 to 1) := (others=>(others=>(others=>'0')));
	     I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	     Vnodal: out matrix(1 to No_Nodes, 1 to 1);
	     Ibranch: out matrix(1 to No_Brn, 1 to 1));
END TOP_LEVEL;

ARCHITECTURE arch of TOP_LEVEL is

COMPONENT PS_SIM
	port(rst,clk: in std_logic;
	     V_s: in matrix(1 to No_Vk, 1 to 1) := (others=>(others=>(others=>'0')));
	     I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	     Vnodal: out matrix(1 to No_Nodes, 1 to 1);
	     Ibranch: out matrix(1 to No_Brn, 1 to 1));
END COMPONENT;

begin

	T1: if (No_Vk /= 0) generate -- Voltage sources are found
		U1: entity work.PS_SIM(arch1) port map(rst=>rst,clk=>clk,V_s=>V_s,I_s=>I_s,Vnodal=>Vnodal,Ibranch=>Ibranch);
	end generate;
	T2: if (No_Vk = 0) generate -- Only current sources are found
		U2: entity work.PS_SIM(arch2) port map(rst=>rst,clk=>clk,V_s=>open,I_s=>I_s,Vnodal=>Vnodal,Ibranch=>Ibranch);
	end generate;
	
end arch;
