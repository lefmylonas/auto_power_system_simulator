LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;
USE WORK.SUPPORT_PACKAGE.ALL;

PACKAGE PS_SIM_PACKAGE IS

constant f_bits: integer :=init_coef(2);
constant No_Nodes: integer :=init_coef(3);
constant No_Brn: integer :=init_coef(4);
constant No_Src: integer :=init_coef(5);
constant No_Vk: integer :=init_coef(6);
constant samples: integer :=init_coef(7);
constant BrnInfo: intmtrx :=init_info("BrnInfo", No_Brn);
constant IsInfo: intmtrx :=init_info("IsInfo", No_Src-No_Vk);
constant Transf: matrix(1 to No_Brn,1 to 3) :=init("Transf", No_Brn, 3);
constant I_hs_coef: matrix(1 to No_Brn, 1 to 2) :=init("I_hs", No_Brn, 2);
constant G_br: matrix(1 to No_Brn, 1 to 1) :=init("G_br", No_Brn, 1);

impure function add_currents(index: integer;
			     I_hs: matrix(1 to No_Brn, 1 to 1);
	 		     I_s: matrix(1 to No_Src-No_Vk, 1 to 1)) return std_logic_vector;
function calc_hist_currents(i: integer;
	                    v,v1: signed(n-1 downto 0)) return std_logic_vector;
function calc_hist_currents(i: integer;
	                    v,v1,v2: signed(n-1 downto 0)) return std_logic_vector;
impure function calc_nodal_voltages(i: integer;
			     	    I_b: matrix(1 to No_Nodes, 1 to 1)) return std_logic_vector;
function calc_branch_currents(i: integer;
			      v,v1: signed(n-1 downto 0)) return std_logic_vector;
function calc_branch_currents(i: integer;
			      v,v1,v2: signed(n-1 downto 0)) return std_logic_vector;

END PS_SIM_PACKAGE;

PACKAGE BODY PS_SIM_PACKAGE IS

impure function add_currents(index: integer;
			     I_hs: matrix(1 to No_Brn, 1 to 1);
	 		     I_s: matrix(1 to No_Src-No_Vk, 1 to 1)) return std_logic_vector is
file inp: text;
variable l: line;
variable s: std_logic_vector(9 downto 0);
variable v: signed(n-1 downto 0) := (others => '0');
variable tmp1: signed(2*n-1 downto 0);
begin

-- Reading BrnInfo matrix
file_open(inp, "BrnInfo.txt", read_mode);
loop1_rows: for i in 1 to No_Brn loop
	loop1_cols: for j in 1 to 2 loop
		readline(inp, l);
		read(l, s);
		if (j = 1) and (to_integer(unsigned(s)) = index) then
			if i /= 1 then
				if signed(Transf(i-1,1)) /= 0 then
					tmp1 := signed(I_hs(i-1,1))*signed(Transf(i-1,1));
	   				v := v + tmp1(n+f_bits-1 downto f_bits);
	   			end if;
			end if;
			v := v - signed(I_hs(i,1));
		elsif (j = 2) and (to_integer(unsigned(s)) = index) then
			if i /= 1 then
				if signed(Transf(i-1,1)) /= 0 then
					tmp1 := signed(I_hs(i-1,1))*signed(Transf(i-1,1));
					v := v - tmp1(n+f_bits-1 downto f_bits);
				end if;
			end if;
			v := v + signed(I_hs(i,1));
		end if;
	end loop;
end loop;
file_close(inp);

-- Reading IsInfo matrix
file_open(inp, "IsInfo.txt", read_mode);
loop2_rows: for i in 1 to No_Src-No_Vk loop
	loop2_cols: for j in 1 to 2 loop
		readline(inp, l);
		read(l, s);
		if (j = 1) and (to_integer(unsigned(s)) = index) then
			v := v - signed(I_s(i,1));
		elsif (j = 2) and (to_integer(unsigned(s)) = index) then
			v := v + signed(I_s(i,1));
		end if;
	end loop;
end loop;
file_close(inp);

return std_logic_vector(v);

end add_currents;

function calc_hist_currents(i: integer;
			    v,v1: signed(n-1 downto 0)) return std_logic_vector is
variable s: std_logic_vector(n-1 downto 0);
variable tmp: signed(2*n-1 downto 0);
begin

if (signed(I_hs_coef(i,1)) /= 0) and (signed(I_hs_coef(i,2)) /= 0) then
	tmp := (signed(I_hs_coef(i,1)) * v) + (signed(I_hs_coef(i,2)) * v1);
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
elsif (signed(I_hs_coef(i,1)) = 0) and (signed(I_hs_coef(i,2)) = 0) then
	s := (others=>'0');
elsif signed(I_hs_coef(i,2)) = 0 then
	tmp := signed(I_hs_coef(i,1)) * v;
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
elsif signed(I_hs_coef(i,1)) = 0 then
	tmp := signed(I_hs_coef(i,2)) * v1;
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
end if;

return s;

end calc_hist_currents;


function calc_hist_currents(i: integer;
	                    v,v1,v2: signed(n-1 downto 0)) return std_logic_vector is
variable s: std_logic_vector(n-1 downto 0);
variable tmp: signed(2*n-1 downto 0);
begin

if (signed(I_hs_coef(i,1)) /= 0) and (signed(I_hs_coef(i,2)) /= 0) then
	tmp := (signed(I_hs_coef(i,1)) * v) + (signed(I_hs_coef(i,2)) * v1) - (signed(Transf(i,2)) * v2);
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
elsif (signed(I_hs_coef(i,1)) = 0) and (signed(I_hs_coef(i,2)) = 0) then
	s := (others=>'0');
elsif signed(I_hs_coef(i,2)) = 0 then
	tmp := (signed(I_hs_coef(i,1)) * v) - (signed(Transf(i,2)) * v2);
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
elsif signed(I_hs_coef(i,1)) = 0 then
	tmp := signed(I_hs_coef(i,2)) * v1;
	s := std_logic_vector(tmp(n+f_bits-1 downto f_bits));
end if;

return s;

end calc_hist_currents;

impure function calc_nodal_voltages(i: integer;
			     	    I_b: matrix(1 to No_Nodes, 1 to 1)) return std_logic_vector is
constant G: matrix(1 to No_Nodes, 1 to No_Nodes) :=init("G", No_Nodes, No_Nodes);
--constant G_UU: matrix(1 to No_Nodes-No_Vk, 1 to No_Nodes-No_Vk) :=init("G_UU", No_Nodes-No_Vk, No_Nodes-No_Vk);
--constant G_UK: matrix(1 to No_Nodes-No_Vk, 1 to No_Vk) :=init("G_UK", No_Nodes-No_Vk, No_Vk);
variable v: signed(2*n-1 downto 0) := (others=>'0');
begin

Vn_calc: for j in 1 to No_Nodes loop
	if signed(G(i,j)) /= 0 then
		v := v + signed(G(i,j))*signed(I_b(j,1));
	end if;
end loop;

return std_logic_vector(v(n+f_bits-1 downto f_bits));

end calc_nodal_voltages;

function calc_branch_currents(i: integer;
			      v,v1: signed(n-1 downto 0)) return std_logic_vector is
variable s: std_logic_vector(n-1 downto 0);
variable tmp1: signed(2*n-1 downto 0);
begin

if signed(G_br(i,1)) /= 0 then
	tmp1 := signed(G_br(i,1)) * v;
	s := std_logic_vector(v1 + tmp1(n+f_bits-1 downto f_bits));
else
	s := std_logic_vector(v1);
end if;

return s;

end calc_branch_currents;


function calc_branch_currents(i: integer;
			      v,v1,v2: signed(n-1 downto 0)) return std_logic_vector is
variable s: std_logic_vector(n-1 downto 0);
variable tmp1: signed(2*n-1 downto 0);
begin

if signed(G_br(i,1)) /= 0 then
	tmp1 := (signed(G_br(i,1)) * v) - (signed(Transf(i,3))*v2);
	s := std_logic_vector(v1 + tmp1(n+f_bits-1 downto f_bits));
else
	s := std_logic_vector(v1);
end if;

return s;

end calc_branch_currents;

END PS_SIM_PACKAGE;