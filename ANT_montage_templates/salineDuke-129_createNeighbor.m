%% Specify neighbors for the salineDuke-129 montage
%
% - creates a channelneighbors matrix specifying the neighbors of each
% electrode according to manual labelling of the hexagonal layout.
%
% Last edit: Alex He 07/14/2026

%%
% We intentionally ignore VEOGL, which is channel 66 in this montage, and
% do not reference it.
channelneighbors = false(129);

% ok let's go!

channelneighbors(1,   [8,9,33,40,41,129]) = 1; % Z2
channelneighbors(2,   [10,11,35,42,43,129]) = 1; % Z4
channelneighbors(3,   [12,13,34,35,44,45]) = 1; % Z6
channelneighbors(4,   [14,15,34,36,46,47]) = 1; % Z8
channelneighbors(5,   [16,17,36,37,48,49]) = 1; % Z10
channelneighbors(6,   [18,19,37,38,50,51]) = 1; % Z12
channelneighbors(7,   [8,21,33,39,85]) = 1; % L1
channelneighbors(8,   [1,7,9,21,22,33]) = 1; % L2
channelneighbors(9,   [1,8,10,22,23,129]) = 1; % L3
channelneighbors(10,  [2,9,11,23,24,129]) = 1; % L4
channelneighbors(11,  [2,10,12,24,25,35]) = 1; % L5
channelneighbors(12,  [3,11,13,25,26,35]) = 1; % L6
channelneighbors(13,  [3,12,14,26,27,34]) = 1; % L7
channelneighbors(14,  [4,13,15,27,28,34]) = 1; % L8
channelneighbors(15,  [4,14,16,28,29,36]) = 1; % L9
channelneighbors(16,  [5,15,17,29,30,36]) = 1; % L10
channelneighbors(17,  [5,16,18,30,31,37]) = 1; % L11
channelneighbors(18,  [6,17,19,31,32,37]) = 1; % L12
channelneighbors(19,  [6,18,20,32,38,65]) = 1; % L13
channelneighbors(20,  [19,38,65,95,98]) = 1; % L14
channelneighbors(21,  [7,8,22,78,85]) = 1; % LL1
channelneighbors(22,  [8,9,21,23,72,78]) = 1; % LL2
channelneighbors(23,  [9,10,22,24,67,72]) = 1; % LL3
channelneighbors(24,  [10,11,23,25,67]) = 1; % LL4
channelneighbors(25,  [11,12,24,26,67,68]) = 1; % LL5
channelneighbors(26,  [12,13,25,27,68,69]) = 1; % LL6
channelneighbors(27,  [13,14,26,28,69,70]) = 1; % LL7
channelneighbors(28,  [14,15,27,29,70,71]) = 1; % LL8
channelneighbors(29,  [15,16,28,30,71,77]) = 1; % LL9
channelneighbors(30,  [16,17,29,31,77,84]) = 1; % LL10
channelneighbors(31,  [17,18,30,32,77,84]) = 1; % LL11
channelneighbors(32,  [18,19,31,65,84,91]) = 1; % LL12
channelneighbors(33,  [1,7,8,39,40]) = 1; % Z1
channelneighbors(34,  [3,4,13,14,45,46]) = 1; % Z7
channelneighbors(35,  [2,3,11,12,43,44]) = 1; % Z5
channelneighbors(36,  [4,5,15,16,47,48]) = 1; % Z9
channelneighbors(37,  [5,6,17,18,49,50]) = 1; % Z11
channelneighbors(38,  [6,19,20,51,52,98]) = 1; % Z13
channelneighbors(39,  [7,33,40,53,117]) = 1; % R1
channelneighbors(40,  [1,33,39,41,53,54]) = 1; % R2
channelneighbors(41,  [1,40,42,54,55,129]) = 1; % R3
channelneighbors(42,  [2,41,43,55,56,129]) = 1; % R4
channelneighbors(43,  [2,35,42,44,56,57]) = 1; % R5
channelneighbors(44,  [3,35,43,45,57,58]) = 1; % R6
channelneighbors(45,  [3,34,44,46,58,59]) = 1; % R7
channelneighbors(46,  [4,34,45,47,59,60]) = 1; % R8
channelneighbors(47,  [4,36,46,48,60,61]) = 1; % R9
channelneighbors(48,  [5,36,47,49,61,62]) = 1; % R10
channelneighbors(49,  [5,37,48,50,62,63]) = 1; % R11
channelneighbors(50,  [6,37,49,51,63,64]) = 1; % R12
channelneighbors(51,  [6,38,50,52,64,97]) = 1; % R13
channelneighbors(52,  [38,51,97,98,127]) = 1; % R14
channelneighbors(53,  [39,40,54,110,117]) = 1; % RR1
channelneighbors(54,  [40,41,53,55,104,110]) = 1; % RR2
channelneighbors(55,  [41,42,54,56,99,104]) = 1; % RR3
channelneighbors(56,  [42,43,55,57,99]) = 1; % RR4
channelneighbors(57,  [43,44,56,58,99,100]) = 1; % RR5
channelneighbors(58,  [44,45,57,59,100,101]) = 1; % RR6
channelneighbors(59,  [45,46,58,60,101,102]) = 1; % RR7
channelneighbors(60,  [46,47,59,61,102,103]) = 1; % RR8
channelneighbors(61,  [47,48,60,62,103,109]) = 1; % RR9
channelneighbors(62,  [48,49,61,63,109,116]) = 1; % RR10
channelneighbors(63,  [49,50,62,64,109,116]) = 1; % RR11
channelneighbors(64,  [50,51,63,97,116,123]) = 1; % RR12
channelneighbors(65,  [19,20,32,91,95]) = 1; % LL13

% Channel 66 (VEOGL) intentionally has no neighbors.

channelneighbors(67,  [23,24,25,68,72,73]) = 1; % LA1
channelneighbors(68,  [25,26,67,69,73,74]) = 1; % LA2
channelneighbors(69,  [26,27,68,70,74,75]) = 1; % LA3
channelneighbors(70,  [27,28,69,71,75,76]) = 1; % LA4
channelneighbors(71,  [28,29,70,76,77]) = 1; % LA5
channelneighbors(72,  [22,23,67,73,78,79]) = 1; % LB1
channelneighbors(73,  [67,68,72,74,79,80]) = 1; % LB2
channelneighbors(74,  [68,69,73,75,80,81]) = 1; % LB3
channelneighbors(75,  [69,70,74,76,81,82]) = 1; % LB4
channelneighbors(76,  [70,71,75,77,82,83]) = 1; % LB5
channelneighbors(77,  [29,30,31,71,76,83,84]) = 1; % LB6
channelneighbors(78,  [21,22,72,79,85,86]) = 1; % LC1
channelneighbors(79,  [72,73,78,80,86,87]) = 1; % LC2
channelneighbors(80,  [73,74,79,81,87,88]) = 1; % LC3
channelneighbors(81,  [74,75,80,82,88,89]) = 1; % LC4
channelneighbors(82,  [75,76,81,83,89,90]) = 1; % LC5
channelneighbors(83,  [76,77,82,84,90]) = 1; % LC6
channelneighbors(84,  [30,31,32,77,83,90,91]) = 1; % LC7
channelneighbors(85,  [7,21,78,86,92]) = 1; % LD1
channelneighbors(86,  [78,79,85,87,92]) = 1; % LD2
channelneighbors(87,  [79,80,86,88,92,93]) = 1; % LD3
channelneighbors(88,  [80,81,87,89,93]) = 1; % LD4
channelneighbors(89,  [81,82,88,90,94,96]) = 1; % LD5
channelneighbors(90,  [82,83,84,89,91,94,96]) = 1; % LD6
channelneighbors(91,  [32,65,84,90,94,95]) = 1; % LD7
channelneighbors(92,  [85,86,87,93]) = 1; % LE1
channelneighbors(93,  [87,88,92]) = 1; % LE2
channelneighbors(94,  [89,90,91,95,96]) = 1; % LE3
channelneighbors(95,  [20,65,91,94]) = 1; % LE4
channelneighbors(96,  [89,90,94]) = 1; % Lm
channelneighbors(97,  [51,52,64,123,127]) = 1; % RR13
channelneighbors(98,  [20,38,52]) = 1; % Z14
channelneighbors(99,  [55,56,57,100,104,105]) = 1; % RA1
channelneighbors(100, [57,58,99,101,105,106]) = 1; % RA2
channelneighbors(101, [58,59,100,102,106,107]) = 1; % RA3
channelneighbors(102, [59,60,101,103,107,108]) = 1; % RA4
channelneighbors(103, [60,61,102,108,109]) = 1; % RA5
channelneighbors(104, [54,55,99,105,110,111]) = 1; % RB1
channelneighbors(105, [99,100,104,106,111,112]) = 1; % RB2
channelneighbors(106, [100,101,105,107,112,113]) = 1; % RB3
channelneighbors(107, [101,102,106,108,113,114]) = 1; % RB4
channelneighbors(108, [102,103,107,109,114,115]) = 1; % RB5
channelneighbors(109, [61,62,63,103,108,115,116]) = 1; % RB6
channelneighbors(110, [53,54,104,111,117,118]) = 1; % RC1
channelneighbors(111, [104,105,110,112,118,119]) = 1; % RC2
channelneighbors(112, [105,106,111,113,119,120]) = 1; % RC3
channelneighbors(113, [106,107,112,114,120,121]) = 1; % RC4
channelneighbors(114, [107,108,113,115,121,122]) = 1; % RC5
channelneighbors(115, [108,109,114,116,122]) = 1; % RC6
channelneighbors(116, [62,63,64,109,115,122,123]) = 1; % RC7
channelneighbors(117, [39,53,110,118,124]) = 1; % RD1
channelneighbors(118, [110,111,117,119,124]) = 1; % RD2
channelneighbors(119, [111,112,118,120,124,125]) = 1; % RD3
channelneighbors(120, [112,113,119,121,125]) = 1; % RD4
channelneighbors(121, [113,114,120,122,126,128]) = 1; % RD5
channelneighbors(122, [114,115,116,121,123,126,128]) = 1; % RD6
channelneighbors(123, [64,97,116,122,126,127]) = 1; % RD7
channelneighbors(124, [117,118,119,125]) = 1; % RE1
channelneighbors(125, [119,120,124]) = 1; % RE2
channelneighbors(126, [121,122,123,127,128]) = 1; % RE3
channelneighbors(127, [52,97,123,126]) = 1; % RE4
channelneighbors(128, [121,122,126]) = 1; % Rm
channelneighbors(129, [1,2,9,10,41,42]) = 1; % Z3

% Check for symmetric matrix
assert(issymmetric(channelneighbors), 'Neighbor matrix is not symmetric! Please check!')

save('salineDuke_129_channelneighbors.mat', 'channelneighbors')
