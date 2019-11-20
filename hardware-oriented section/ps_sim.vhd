LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY PS_SIM is
	port(rst,clk: in std_logic;
	     I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	     Vnodal: out matrix(1 to No_Nodes, 1 to 1);
	     Ibranch: out matrix(1 to No_Brn, 1 to 1));
END PS_SIM;

ARCHITECTURE arch1 of PS_SIM is -- Voltage sources are found

begin


end arch1;


ARCHITECTURE arch2 of PS_SIM is -- Only current sources are found

COMPONENT BRANCH_VOLTAGES
	port(V_n: in matrix(1 to No_Nodes, 1 to 1);
	     V_branch: out matrix(1 to No_Brn, 1 to 1));
END COMPONENT;

COMPONENT HISTORY_CURRENTS
	port(V_branch, I_br: in matrix(1 to No_Brn, 1 to 1);
	     I_hs: out matrix(1 to No_Brn, 1 to 1));
END COMPONENT;

COMPONENT NODAL_CURRENTS
    port(I_hs: in matrix(1 to No_Brn, 1 to 1);
	 I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	 I_b: out matrix(1 to No_Nodes, 1 to 1));
END COMPONENT;

COMPONENT NODAL_VOLTAGES
    port(I_b: in matrix(1 to No_Nodes, 1 to 1);
	 V_n: out matrix(1 to No_Nodes, 1 to 1));
END COMPONENT;

COMPONENT BRANCH_CURRENTS
	port(V_branch, I_hs: in matrix(1 to No_Brn, 1 to 1);
	     I_br: out matrix(1 to No_Brn, 1 to 1));
END COMPONENT;

signal V_branch, I_hs, I_br, reg_Vbranch, reg_Ibr: matrix(1 to No_Brn, 1 to 1);
signal V_n,I_b,reg_Vn: matrix(1 to No_Nodes, 1 to 1);
signal reg_Is: matrix(1 to No_Src-No_Vk, 1 to 1);
begin

	S1: HISTORY_CURRENTS port map(V_branch=>reg_Vbranch, I_br=>reg_Ibr, I_hs=>I_hs);
	S2: NODAL_CURRENTS port map(I_hs=>I_hs, I_s=>reg_Is, I_b=>I_b);
	S3: NODAL_VOLTAGES port map(I_b=>I_b, V_n=>V_n);
	S4: BRANCH_VOLTAGES port map(V_n=>V_n, V_branch=>V_branch);
	S5: BRANCH_CURRENTS port map(V_branch=>V_branch, I_hs=>I_hs, I_br=>I_br);
	Vnodal <= reg_Vn;
	Ibranch <= reg_Ibr;

	process(rst,clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				reg_Vbranch <= init("V_branch", No_Brn, 1);
				reg_Vn <= init("V_n", No_Nodes, 1);
				reg_Ibr <= init("I_br", No_Brn, 1);
				reg_Is <= init("I_s", No_Src-No_Vk, 1);
			else			
				reg_Vbranch <= V_branch;
				reg_Vn <= V_n;
				reg_Ibr <= I_br;
				reg_Is <= I_s;
			end if;
		end if;
	end process;

end arch2;