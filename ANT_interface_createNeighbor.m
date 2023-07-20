%%
% ANT INTERFACE SCRIPT - CREATENEIGHBOR
%
% - creates a channelneighbors matrix specifying the neighbors of each
% electrode according to manual labelling of the hexagonal layout.
%
% Last edit: Alex He 02/08/2020

%%
% we intentionally ignore channel 129 that is the EOG electrode and we do
% not reference it.
channelneighbors = false(128);

% ok let's go!

channelneighbors(1,   [4,6,126]) = 1;
channelneighbors(2,   [3,5,123,124]) = 1;
channelneighbors(3,   [2,124,125]) = 1;
channelneighbors(4,   [1,6,126,127,128]) = 1;
channelneighbors(5,   [2,118,119,123,124]) = 1;
channelneighbors(6,   [1,4,120,121,125,126]) = 1;
channelneighbors(7,   [114,115,119,120,124,125]) = 1;
channelneighbors(8,   [116,117,121,122,126]) = 1;
channelneighbors(9,   [103,104,111,114,118,119]) = 1;
channelneighbors(10,  [112,113,115,116,120,121]) = 1;
channelneighbors(11,  [105,106,111,112,114,115]) = 1;
channelneighbors(12,  [107,108,113,116,117]) = 1;
channelneighbors(13,  [93,94,103,118,123]) = 1;
channelneighbors(14,  [95,96,104,105,111]) = 1;
channelneighbors(15,  [97,98,106,107,112,113]) = 1;
channelneighbors(16,  [99,100,108,109,117,122]) = 1;
channelneighbors(17,  [101,102,110,127,128]) = 1;
channelneighbors(18,  [84,85,94,95,103,104]) = 1;
channelneighbors(19,  [86,87,96,97,105,106]) = 1;
channelneighbors(20,  [88,89,98,99,107,108]) = 1;
channelneighbors(21,  [90,91,100,101,109,110]) = 1;
channelneighbors(22,  [74,75,84,93,94]) = 1;
channelneighbors(23,  [76,77,85,86,95,96]) = 1;
channelneighbors(24,  [78,79,87,88,97,98]) = 1;
channelneighbors(25,  [80,81,89,90,99,100]) = 1;
channelneighbors(26,  [82,83,91,92,101,102]) = 1;
channelneighbors(27,  [66,67,75,76,84,85]) = 1;
channelneighbors(28,  [68,69,77,78,86,87]) = 1;
channelneighbors(29,  [70,71,79,80,88,89]) = 1;
channelneighbors(30,  [72,73,81,82,90,91]) = 1;
channelneighbors(31,  [49,54,66,74,75]) = 1;
channelneighbors(32,  [63,67,68,76,77]) = 1;
channelneighbors(33,  [64,65,69,70,78,79]) = 1;
channelneighbors(34,  [58,62,71,72,80,81]) = 1;
channelneighbors(35,  [48,53,73,82,83]) = 1;
channelneighbors(36,  [59,60,63,64,68,69]) = 1;
channelneighbors(37,  [61,62,65,70,71]) = 1;
channelneighbors(38,  [54,55,59,63,66,67]) = 1;
channelneighbors(39,  [56,57,60,61,64,65]) = 1;
channelneighbors(40,  [50,51,55,56,59,60]) = 1;
channelneighbors(41,  [52,57,58,61,62]) = 1;
channelneighbors(42,  [44,49,50,54,55]) = 1;
channelneighbors(43,  [46,47,51,52,56,57]) = 1;
channelneighbors(44,  [42,45,49,50]) = 1;
channelneighbors(45,  [44,50,51]) = 1;
channelneighbors(46,  [43,47,48,52,53]) = 1;
channelneighbors(47,  [43,46,52]) = 1;
channelneighbors(48,  [35,46,53,83]) = 1;
channelneighbors(49,  [31,42,44,54,74]) = 1;
channelneighbors(50,  [40,42,44,45,51,55]) = 1;
channelneighbors(51,  [40,43,45,50,56]) = 1;
channelneighbors(52,  [41,43,46,47,53,57,58]) = 1;
channelneighbors(53,  [35,46,48,52,58,73]) = 1;
channelneighbors(54,  [31,38,42,49,55,66]) = 1;
channelneighbors(55,  [38,40,42,50,54,59]) = 1;
channelneighbors(56,  [39,40,43,51,57,60]) = 1;
channelneighbors(57,  [39,41,43,52,56,61]) = 1;
channelneighbors(58,  [34,41,52,53,62,72,73]) = 1;
channelneighbors(59,  [36,38,40,55,60,63]) = 1;
channelneighbors(60,  [36,39,40,56,59,64]) = 1;
channelneighbors(61,  [37,39,41,57,62,65]) = 1;
channelneighbors(62,  [34,37,41,58,61,71,72]) = 1;
channelneighbors(63,  [32,36,38,59,67,68]) = 1;
channelneighbors(64,  [33,36,39,60,65,69]) = 1;
% jesus chris
channelneighbors(65,  [33,37,39,61,64,70]) = 1;
channelneighbors(66,  [27,31,38,54,67,75]) = 1;
channelneighbors(67,  [27,32,38,63,66,76]) = 1;
channelneighbors(68,  [28,32,36,63,69,77]) = 1;
channelneighbors(69,  [28,33,36,64,68,78]) = 1;
channelneighbors(70,  [29,33,37,65,71,79]) = 1;
channelneighbors(71,  [29,34,37,62,70,80]) = 1;
channelneighbors(72,  [30,34,58,62,73,81]) = 1;
channelneighbors(73,  [30,35,53,58,72,82]) = 1;
channelneighbors(74,  [22,31,49,75,93]) = 1;
channelneighbors(75,  [22,27,31,66,74,84]) = 1;
channelneighbors(76,  [23,27,32,67,77,85]) = 1;
channelneighbors(77,  [23,28,32,68,76,86]) = 1;
channelneighbors(78,  [24,28,33,69,79,87]) = 1;
channelneighbors(79,  [24,29,33,70,78,88]) = 1;
channelneighbors(80,  [25,29,34,71,81,89]) = 1;
channelneighbors(81,  [25,30,34,72,80,90]) = 1;
channelneighbors(82,  [26,30,35,73,83,91]) = 1;
channelneighbors(83,  [26,35,48,82,92]) = 1;
channelneighbors(84,  [18,22,27,75,85,94]) = 1;
channelneighbors(85,  [18,23,27,76,84,95]) = 1;
channelneighbors(86,  [19,23,28,77,87,96]) = 1;
channelneighbors(87,  [19,24,28,78,86,97]) = 1;
channelneighbors(88,  [20,24,29,79,89,98]) = 1;
channelneighbors(89,  [20,25,29,80,88,99]) = 1;
channelneighbors(90,  [21,25,30,81,91,100]) = 1;
channelneighbors(91,  [21,26,30,82,90,101]) = 1;
channelneighbors(92,  [26,83,102]) = 1;
channelneighbors(93,  [13,22,74,94,123]) = 1;
channelneighbors(94,  [13,18,22,84,93,103]) = 1;
channelneighbors(95,  [14,18,23,85,96,104]) = 1;
channelneighbors(96,  [14,19,23,86,95,105]) = 1;
channelneighbors(97,  [15,19,24,87,98,106]) = 1;
channelneighbors(98,  [15,20,24,88,97,107]) = 1;
channelneighbors(99,  [16,20,25,89,100,108]) = 1;
channelneighbors(100, [16,21,25,90,99,109]) = 1;
channelneighbors(101, [17,21,26,91,102,110]) = 1;
channelneighbors(102, [17,26,92,101,128]) = 1;
channelneighbors(103, [9,13,18,94,104,118]) = 1;
channelneighbors(104, [9,14,18,95,103,111]) = 1;
channelneighbors(105, [11,14,19,96,106,111]) = 1;
channelneighbors(106, [11,15,19,97,105,112]) = 1;
channelneighbors(107, [12,15,20,98,108,113]) = 1;
channelneighbors(108, [12,16,20,99,107,117]) = 1;
channelneighbors(109, [16,21,100,110,117,122]) = 1;
channelneighbors(110, [17,21,101,109,122,127]) = 1;
channelneighbors(111, [9,11,14,104,105,114]) = 1;
channelneighbors(112, [10,11,15,106,113,115]) = 1;
channelneighbors(113, [10,12,15,107,112,116]) = 1;
channelneighbors(114, [9,7,11,111,115,119]) = 1;
channelneighbors(115, [7,10,11,112,114,120]) = 1;
channelneighbors(116, [8,10,12,113,117,121]) = 1;
channelneighbors(117, [8,12,16,108,109,116,122]) = 1;
channelneighbors(118, [5,9,13,103,123,119]) = 1;
channelneighbors(119, [5,7,9,114,118,124]) = 1;
channelneighbors(120, [6,7,10,115,121,125]) = 1;
channelneighbors(121, [6,8,10,116,120,126]) = 1;
channelneighbors(122, [8,16,109,110,117,126,127]) = 1;
channelneighbors(123, [2,5,13,93,118]) = 1;
channelneighbors(124, [2,3,5,7,119,125]) = 1;
channelneighbors(125, [3,6,7,120,124]) = 1;
channelneighbors(126, [1,4,6,8,121,122,127]) = 1;
channelneighbors(127, [4,17,110,122,126,128]) = 1;
channelneighbors(128, [4,17,102,127]) = 1;
% is anyone reading this? this took me 3hrs!

% Check for symmetric matrix 
assert(issymmetric(channelneighbors), 'Neighbor matrix is not symmetric! Please check!')

save('duke_128_channelneighbors', 'channelneighbors')
