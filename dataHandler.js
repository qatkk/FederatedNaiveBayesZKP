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
    dataNo = reshaped.length; 
    trainNo = math.floor(dataNo * ratio) ; 
    testN = dataNo - trainNo ; 
    idx = Array(trainNo).fill().map((x) => {
        return math.floor(math.random() * dataNo)
    });
    idx = idx.sort();


    console.log("data size is ", dataNo); 
    console.log("train data size is ", trainNo); 
    console.log(idx);
    test = [] ; 
    train = []; 

    for (let i=0; i < dataNo; i++) { 
        if (idx.includes(i)){
            repeated  = idx.indexOf(i);
            while (idx[repeated] == i) {
                train.push(reshaped[i]);
                repeated += 1 ; 
            }
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

