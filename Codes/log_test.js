const { json, sec, log, pow } = require("mathjs");
//  0 -> Varience 
//  1 -> Mean
let global = [200, 100]; 
let local = [500, 100]; 
let input = (local[0] )/ global[0]; 
let estimation = (input - 1)*100 - (0.5) * ((input - 1)* 10)**2 - (1/3) * ((input -1 )* 5)**3 - (1/4) * ((input - 1)* 3) ** 4; 
let dm_estimation  = estimation + ((global[0]**2 + ((global[1] - local[1]) **2 ))/ (0.02 * global[0] **2)) - 0.5 ; 
let dm = log(input ** 100)+ ((global[0] ** 2 + ((global[1] - local[1]) **2 ))/ (0.02 * global[0] **2)) - 0.5 ;
console.log("the estimation is ", dm_estimation, " the real answer is ", dm);