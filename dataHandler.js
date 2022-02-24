const fs = require("fs"); 
const mathjs = require("mathjs"); 
const math = require ('math');


function readCSV (filename, NumberOfFeatures) {
    raw = fs.readFileSync(filename+'.csv', 'utf-8'); 
    raw = raw.split(","); 

    reshaped = mathjs.reshape(raw, [raw.length/NumberOfFeatures, NumberOfFeatures]);
    return reshaped;
}
function trainTestSplit (reshaped, ratio) {
    dataNu = reshaped.length; 
    train = math.floor(dataNu * ratio) ; 
    test = dataNu - train ; 
    idx = Array.from({length: train}, () => math.floor(math.random() * dataNu));



    console.log("data size is ", dataNu); 
    console.log("train data size is ", train); 

    test = [] ; 
    train = []; 

    // for (i=0 ; i< idx.length; i++) { 
    //     train.push(reshaped[idx[i]]); 
    // } 
    // for (i=0 ; i<dataNu; i++) {
    //     if (! train.includes(reshaped[i])){
    //         test.push(reshaped[i]);
    //     }
    // }
    for (i=0; i< dataNu; i++) { 
        if (idx.includes(i)){
            train.push(reshaped[i]);
        }
        else {
            test.push(reshaped[i]);
        }
    }
        return {
            test: test, 
            train: train
        };
}


exports.trainTestSplit = trainTestSplit; 
exports.readCSV = readCSV; 

