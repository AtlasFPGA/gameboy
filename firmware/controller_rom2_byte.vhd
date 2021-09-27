
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"40",x"7c",x"3c",x"00"),
     1 => (x"00",x"7c",x"7c",x"40"),
     2 => (x"60",x"3c",x"1c",x"00"),
     3 => (x"00",x"1c",x"3c",x"60"),
     4 => (x"30",x"60",x"7c",x"3c"),
     5 => (x"00",x"3c",x"7c",x"60"),
     6 => (x"10",x"38",x"6c",x"44"),
     7 => (x"00",x"44",x"6c",x"38"),
     8 => (x"e0",x"bc",x"1c",x"00"),
     9 => (x"00",x"1c",x"3c",x"60"),
    10 => (x"74",x"64",x"44",x"00"),
    11 => (x"00",x"44",x"4c",x"5c"),
    12 => (x"3e",x"08",x"08",x"00"),
    13 => (x"00",x"41",x"41",x"77"),
    14 => (x"7f",x"00",x"00",x"00"),
    15 => (x"00",x"00",x"00",x"7f"),
    16 => (x"77",x"41",x"41",x"00"),
    17 => (x"00",x"08",x"08",x"3e"),
    18 => (x"03",x"01",x"01",x"02"),
    19 => (x"00",x"01",x"02",x"02"),
    20 => (x"7f",x"7f",x"7f",x"7f"),
    21 => (x"00",x"7f",x"7f",x"7f"),
    22 => (x"1c",x"1c",x"08",x"08"),
    23 => (x"7f",x"7f",x"3e",x"3e"),
    24 => (x"3e",x"3e",x"7f",x"7f"),
    25 => (x"08",x"08",x"1c",x"1c"),
    26 => (x"7c",x"18",x"10",x"00"),
    27 => (x"00",x"10",x"18",x"7c"),
    28 => (x"7c",x"30",x"10",x"00"),
    29 => (x"00",x"10",x"30",x"7c"),
    30 => (x"60",x"60",x"30",x"10"),
    31 => (x"00",x"06",x"1e",x"78"),
    32 => (x"18",x"3c",x"66",x"42"),
    33 => (x"00",x"42",x"66",x"3c"),
    34 => (x"c2",x"6a",x"38",x"78"),
    35 => (x"00",x"38",x"6c",x"c6"),
    36 => (x"60",x"00",x"00",x"60"),
    37 => (x"00",x"60",x"00",x"00"),
    38 => (x"5c",x"5b",x"5e",x"0e"),
    39 => (x"86",x"fc",x"0e",x"5d"),
    40 => (x"e6",x"c2",x"7e",x"71"),
    41 => (x"c0",x"4c",x"bf",x"ec"),
    42 => (x"c4",x"1e",x"c0",x"4b"),
    43 => (x"c4",x"02",x"ab",x"66"),
    44 => (x"c2",x"4d",x"c0",x"87"),
    45 => (x"75",x"4d",x"c1",x"87"),
    46 => (x"ee",x"49",x"73",x"1e"),
    47 => (x"86",x"c8",x"87",x"e2"),
    48 => (x"ef",x"49",x"e0",x"c0"),
    49 => (x"a4",x"c4",x"87",x"eb"),
    50 => (x"f0",x"49",x"6a",x"4a"),
    51 => (x"c9",x"f1",x"87",x"f2"),
    52 => (x"c1",x"84",x"cc",x"87"),
    53 => (x"ab",x"b7",x"c8",x"83"),
    54 => (x"87",x"cd",x"ff",x"04"),
    55 => (x"4d",x"26",x"8e",x"fc"),
    56 => (x"4b",x"26",x"4c",x"26"),
    57 => (x"71",x"1e",x"4f",x"26"),
    58 => (x"f0",x"e6",x"c2",x"4a"),
    59 => (x"f0",x"e6",x"c2",x"5a"),
    60 => (x"49",x"78",x"c7",x"48"),
    61 => (x"26",x"87",x"e1",x"fe"),
    62 => (x"1e",x"73",x"1e",x"4f"),
    63 => (x"b7",x"c0",x"4a",x"71"),
    64 => (x"87",x"d3",x"03",x"aa"),
    65 => (x"bf",x"e4",x"d2",x"c2"),
    66 => (x"c1",x"87",x"c4",x"05"),
    67 => (x"c0",x"87",x"c2",x"4b"),
    68 => (x"e8",x"d2",x"c2",x"4b"),
    69 => (x"c2",x"87",x"c4",x"5b"),
    70 => (x"fc",x"5a",x"e8",x"d2"),
    71 => (x"e4",x"d2",x"c2",x"48"),
    72 => (x"c1",x"4a",x"78",x"bf"),
    73 => (x"a2",x"c0",x"c1",x"9a"),
    74 => (x"87",x"e7",x"ec",x"49"),
    75 => (x"4f",x"26",x"4b",x"26"),
    76 => (x"c4",x"4a",x"71",x"1e"),
    77 => (x"49",x"72",x"1e",x"66"),
    78 => (x"fc",x"87",x"f1",x"eb"),
    79 => (x"1e",x"4f",x"26",x"8e"),
    80 => (x"c3",x"48",x"d4",x"ff"),
    81 => (x"d0",x"ff",x"78",x"ff"),
    82 => (x"78",x"e1",x"c0",x"48"),
    83 => (x"c1",x"48",x"d4",x"ff"),
    84 => (x"c4",x"48",x"71",x"78"),
    85 => (x"08",x"d4",x"ff",x"30"),
    86 => (x"48",x"d0",x"ff",x"78"),
    87 => (x"26",x"78",x"e0",x"c0"),
    88 => (x"5b",x"5e",x"0e",x"4f"),
    89 => (x"f0",x"0e",x"5d",x"5c"),
    90 => (x"c8",x"7e",x"c0",x"86"),
    91 => (x"bf",x"ec",x"48",x"a6"),
    92 => (x"c2",x"80",x"fc",x"78"),
    93 => (x"78",x"bf",x"ec",x"e6"),
    94 => (x"bf",x"f4",x"e6",x"c2"),
    95 => (x"4c",x"bf",x"e8",x"4d"),
    96 => (x"bf",x"e4",x"d2",x"c2"),
    97 => (x"87",x"fe",x"e3",x"49"),
    98 => (x"f6",x"e8",x"49",x"c7"),
    99 => (x"c2",x"49",x"70",x"87"),
   100 => (x"87",x"d0",x"05",x"99"),
   101 => (x"bf",x"dc",x"d2",x"c2"),
   102 => (x"c8",x"b9",x"ff",x"49"),
   103 => (x"99",x"c1",x"99",x"66"),
   104 => (x"87",x"c2",x"c2",x"02"),
   105 => (x"cb",x"49",x"e8",x"cf"),
   106 => (x"a6",x"d0",x"87",x"fe"),
   107 => (x"e8",x"49",x"c7",x"58"),
   108 => (x"98",x"70",x"87",x"d1"),
   109 => (x"c8",x"87",x"c9",x"05"),
   110 => (x"99",x"c1",x"49",x"66"),
   111 => (x"87",x"c6",x"c1",x"02"),
   112 => (x"c8",x"4b",x"66",x"cc"),
   113 => (x"bf",x"ec",x"48",x"a6"),
   114 => (x"e4",x"d2",x"c2",x"78"),
   115 => (x"f5",x"e2",x"49",x"bf"),
   116 => (x"cb",x"49",x"73",x"87"),
   117 => (x"98",x"70",x"87",x"de"),
   118 => (x"c2",x"87",x"d7",x"02"),
   119 => (x"49",x"bf",x"d8",x"d2"),
   120 => (x"d2",x"c2",x"b9",x"c1"),
   121 => (x"fd",x"71",x"59",x"dc"),
   122 => (x"e8",x"cf",x"87",x"d5"),
   123 => (x"87",x"f8",x"ca",x"49"),
   124 => (x"49",x"c7",x"4b",x"70"),
   125 => (x"70",x"87",x"cc",x"e7"),
   126 => (x"c6",x"ff",x"05",x"98"),
   127 => (x"49",x"66",x"c8",x"87"),
   128 => (x"fe",x"05",x"99",x"c1"),
   129 => (x"d2",x"c2",x"87",x"fd"),
   130 => (x"c1",x"4a",x"bf",x"e4"),
   131 => (x"e8",x"d2",x"c2",x"ba"),
   132 => (x"7a",x"0a",x"fc",x"5a"),
   133 => (x"c1",x"9a",x"c1",x"0a"),
   134 => (x"e8",x"49",x"a2",x"c0"),
   135 => (x"da",x"c1",x"87",x"f5"),
   136 => (x"87",x"df",x"e6",x"49"),
   137 => (x"d2",x"c2",x"7e",x"c1"),
   138 => (x"66",x"c8",x"48",x"dc"),
   139 => (x"e4",x"d2",x"c2",x"78"),
   140 => (x"c7",x"c1",x"05",x"bf"),
   141 => (x"c0",x"c0",x"c8",x"87"),
   142 => (x"d0",x"d3",x"c2",x"4b"),
   143 => (x"49",x"15",x"4d",x"7e"),
   144 => (x"87",x"ff",x"e5",x"49"),
   145 => (x"c0",x"02",x"98",x"70"),
   146 => (x"b4",x"73",x"87",x"c2"),
   147 => (x"05",x"2b",x"b7",x"c1"),
   148 => (x"74",x"87",x"eb",x"ff"),
   149 => (x"99",x"ff",x"c3",x"49"),
   150 => (x"49",x"c0",x"1e",x"71"),
   151 => (x"74",x"87",x"d1",x"fb"),
   152 => (x"29",x"b7",x"c8",x"49"),
   153 => (x"49",x"c1",x"1e",x"71"),
   154 => (x"c8",x"87",x"c5",x"fb"),
   155 => (x"49",x"fd",x"c3",x"86"),
   156 => (x"c3",x"87",x"d0",x"e5"),
   157 => (x"ca",x"e5",x"49",x"fa"),
   158 => (x"87",x"fd",x"c7",x"87"),
   159 => (x"ff",x"c3",x"49",x"74"),
   160 => (x"2c",x"b7",x"c8",x"99"),
   161 => (x"9c",x"74",x"b4",x"71"),
   162 => (x"87",x"e5",x"c0",x"02"),
   163 => (x"ff",x"48",x"a6",x"c8"),
   164 => (x"c8",x"78",x"bf",x"c8"),
   165 => (x"d2",x"c2",x"49",x"66"),
   166 => (x"c2",x"89",x"bf",x"e0"),
   167 => (x"c0",x"03",x"a9",x"e0"),
   168 => (x"4c",x"c0",x"87",x"c5"),
   169 => (x"c2",x"87",x"d0",x"c0"),
   170 => (x"c8",x"48",x"e0",x"d2"),
   171 => (x"c6",x"c0",x"78",x"66"),
   172 => (x"e0",x"d2",x"c2",x"87"),
   173 => (x"74",x"78",x"c0",x"48"),
   174 => (x"05",x"99",x"c8",x"49"),
   175 => (x"c3",x"87",x"ce",x"c0"),
   176 => (x"fe",x"e3",x"49",x"f5"),
   177 => (x"c2",x"49",x"70",x"87"),
   178 => (x"e7",x"c0",x"02",x"99"),
   179 => (x"f0",x"e6",x"c2",x"87"),
   180 => (x"ca",x"c0",x"02",x"bf"),
   181 => (x"88",x"c1",x"48",x"87"),
   182 => (x"58",x"f4",x"e6",x"c2"),
   183 => (x"c4",x"87",x"d3",x"c0"),
   184 => (x"e0",x"c1",x"48",x"66"),
   185 => (x"6e",x"7e",x"70",x"80"),
   186 => (x"c5",x"c0",x"02",x"bf"),
   187 => (x"49",x"ff",x"4b",x"87"),
   188 => (x"7e",x"c1",x"0f",x"73"),
   189 => (x"99",x"c4",x"49",x"74"),
   190 => (x"87",x"ce",x"c0",x"05"),
   191 => (x"e3",x"49",x"f2",x"c3"),
   192 => (x"49",x"70",x"87",x"c1"),
   193 => (x"c0",x"02",x"99",x"c2"),
   194 => (x"e6",x"c2",x"87",x"ed"),
   195 => (x"48",x"7e",x"bf",x"f0"),
   196 => (x"03",x"a8",x"b7",x"c7"),
   197 => (x"6e",x"87",x"cb",x"c0"),
   198 => (x"c2",x"80",x"c1",x"48"),
   199 => (x"c0",x"58",x"f4",x"e6"),
   200 => (x"66",x"c4",x"87",x"d3"),
   201 => (x"80",x"e0",x"c1",x"48"),
   202 => (x"bf",x"6e",x"7e",x"70"),
   203 => (x"87",x"c5",x"c0",x"02"),
   204 => (x"73",x"49",x"fe",x"4b"),
   205 => (x"c3",x"7e",x"c1",x"0f"),
   206 => (x"c6",x"e2",x"49",x"fd"),
   207 => (x"c2",x"49",x"70",x"87"),
   208 => (x"e3",x"c0",x"02",x"99"),
   209 => (x"f0",x"e6",x"c2",x"87"),
   210 => (x"c9",x"c0",x"02",x"bf"),
   211 => (x"f0",x"e6",x"c2",x"87"),
   212 => (x"c0",x"78",x"c0",x"48"),
   213 => (x"66",x"c4",x"87",x"d0"),
   214 => (x"82",x"e0",x"c1",x"4a"),
   215 => (x"c5",x"c0",x"02",x"6a"),
   216 => (x"49",x"fd",x"4b",x"87"),
   217 => (x"7e",x"c1",x"0f",x"73"),
   218 => (x"e1",x"49",x"fa",x"c3"),
   219 => (x"49",x"70",x"87",x"d5"),
   220 => (x"c0",x"02",x"99",x"c2"),
   221 => (x"e6",x"c2",x"87",x"ea"),
   222 => (x"c7",x"48",x"bf",x"f0"),
   223 => (x"c0",x"03",x"a8",x"b7"),
   224 => (x"e6",x"c2",x"87",x"c9"),
   225 => (x"78",x"c7",x"48",x"f0"),
   226 => (x"c4",x"87",x"d3",x"c0"),
   227 => (x"e0",x"c1",x"48",x"66"),
   228 => (x"6e",x"7e",x"70",x"80"),
   229 => (x"c5",x"c0",x"02",x"bf"),
   230 => (x"49",x"fc",x"4b",x"87"),
   231 => (x"7e",x"c1",x"0f",x"73"),
   232 => (x"f0",x"c3",x"48",x"74"),
   233 => (x"58",x"a6",x"cc",x"98"),
   234 => (x"c0",x"05",x"98",x"70"),
   235 => (x"da",x"c1",x"87",x"ce"),
   236 => (x"87",x"cf",x"e0",x"49"),
   237 => (x"99",x"c2",x"49",x"70"),
   238 => (x"87",x"c1",x"c2",x"02"),
   239 => (x"c3",x"49",x"e8",x"cf"),
   240 => (x"a6",x"d0",x"87",x"e6"),
   241 => (x"e8",x"e6",x"c2",x"58"),
   242 => (x"c2",x"50",x"c0",x"48"),
   243 => (x"bf",x"97",x"e8",x"e6"),
   244 => (x"87",x"d9",x"c1",x"05"),
   245 => (x"c0",x"05",x"66",x"c8"),
   246 => (x"da",x"c1",x"87",x"cd"),
   247 => (x"e2",x"df",x"ff",x"49"),
   248 => (x"02",x"98",x"70",x"87"),
   249 => (x"e8",x"87",x"c6",x"c1"),
   250 => (x"c3",x"49",x"4b",x"bf"),
   251 => (x"b7",x"c8",x"99",x"ff"),
   252 => (x"c2",x"b3",x"71",x"2b"),
   253 => (x"49",x"bf",x"e4",x"d2"),
   254 => (x"87",x"ca",x"da",x"ff"),
   255 => (x"c2",x"49",x"66",x"cc"),
   256 => (x"98",x"70",x"87",x"f2"),
   257 => (x"87",x"c6",x"c0",x"02"),
   258 => (x"48",x"e8",x"e6",x"c2"),
   259 => (x"e6",x"c2",x"50",x"c1"),
   260 => (x"05",x"bf",x"97",x"e8"),
   261 => (x"73",x"87",x"d6",x"c0"),
   262 => (x"99",x"f0",x"c3",x"49"),
   263 => (x"87",x"c7",x"ff",x"05"),
   264 => (x"ff",x"49",x"da",x"c1"),
   265 => (x"70",x"87",x"dc",x"de"),
   266 => (x"fa",x"fe",x"05",x"98"),
   267 => (x"f0",x"e6",x"c2",x"87"),
   268 => (x"cc",x"4b",x"49",x"bf"),
   269 => (x"83",x"66",x"c4",x"93"),
   270 => (x"73",x"71",x"4b",x"6b"),
   271 => (x"02",x"9d",x"75",x"0f"),
   272 => (x"6d",x"87",x"e9",x"c0"),
   273 => (x"87",x"e4",x"c0",x"02"),
   274 => (x"dd",x"ff",x"49",x"6d"),
   275 => (x"49",x"70",x"87",x"f5"),
   276 => (x"c0",x"02",x"99",x"c1"),
   277 => (x"a5",x"c4",x"87",x"cb"),
   278 => (x"f0",x"e6",x"c2",x"4b"),
   279 => (x"4b",x"6b",x"49",x"bf"),
   280 => (x"02",x"85",x"c8",x"0f"),
   281 => (x"6d",x"87",x"c5",x"c0"),
   282 => (x"87",x"dc",x"ff",x"05"),
   283 => (x"c8",x"c0",x"02",x"6e"),
   284 => (x"f0",x"e6",x"c2",x"87"),
   285 => (x"df",x"f0",x"49",x"bf"),
   286 => (x"26",x"8e",x"f0",x"87"),
   287 => (x"26",x"4c",x"26",x"4d"),
   288 => (x"00",x"4f",x"26",x"4b"),
   289 => (x"00",x"00",x"00",x"10"),
   290 => (x"14",x"11",x"12",x"58"),
   291 => (x"23",x"1c",x"1b",x"1d"),
   292 => (x"94",x"91",x"59",x"5a"),
   293 => (x"f4",x"eb",x"f2",x"f5"),
   294 => (x"00",x"00",x"00",x"00"),
   295 => (x"00",x"00",x"00",x"00"),
   296 => (x"00",x"00",x"00",x"00"),
   297 => (x"00",x"00",x"00",x"00"),
   298 => (x"ff",x"4a",x"71",x"1e"),
   299 => (x"72",x"49",x"bf",x"c8"),
   300 => (x"4f",x"26",x"48",x"a1"),
   301 => (x"bf",x"c8",x"ff",x"1e"),
   302 => (x"c0",x"c0",x"fe",x"89"),
   303 => (x"a9",x"c0",x"c0",x"c0"),
   304 => (x"c0",x"87",x"c4",x"01"),
   305 => (x"c1",x"87",x"c2",x"4a"),
   306 => (x"26",x"48",x"72",x"4a"),
   307 => (x"00",x"00",x"00",x"4f"),
   308 => (x"11",x"14",x"12",x"58"),
   309 => (x"23",x"1c",x"1b",x"1d"),
   310 => (x"91",x"94",x"59",x"5a"),
   311 => (x"f4",x"eb",x"f2",x"f5"),
   312 => (x"00",x"00",x"24",x"e4"),
   313 => (x"4f",x"54",x"55",x"41"),
   314 => (x"54",x"4f",x"4f",x"42"),
   315 => (x"ab",x"00",x"42",x"47"),
   316 => (x"ab",x"00",x"00",x"19"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;
