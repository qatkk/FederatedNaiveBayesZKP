const { transpose, mean, std, indexDependencies, i, multiply, floor } = require('mathjs');
const {readCSV, trainTestSplit} = require('./dataHandler'); 
const gaussian = require("normal-distribution");
const  NormalDistribution  = require('gaussian');
const argmax = require('compute-argmax');


NumberOfFeatures = 5; 
data = readCSV('iris', NumberOfFeatures); 
console.log(data.length);
res = trainTestSplit(data, 0.8); 


idx = []; 
target = ['Iris-virginica', 'Iris-versicolor', 'Iris-setosa']; 

console.log(res.train.length);
coll = transpose(res.train);


means = Array(NumberOfFeatures - 1).fill().map(() => Array(target.length).fill(0));
stds = Array(NumberOfFeatures - 1 ).fill().map(() => Array(target.length).fill(0));
for (let i= 0; i < target.length; i++) { 
    idx.push(coll[4].indexOf(target[i]));
}

// sort string values in order of occurence 
idx = idx.sort();
console.log(idx);
for (let i = 0 ; i<target.length ; i++) { 
    target[i] = coll[4][idx[i]];
}
idx.push(coll[4].length); 
console.log(target);
console.log(idx[1]);
console.log(coll.map(x => x.slice(0, idx[1])));
distributions = [[]];
for (let i=0; i < coll.length-1 ; i++) {
    arr = coll[i]; 
    for (let j=0; j< target.length; j++) {
        ll = arr.slice(idx[j], idx[j+1]-1);
        means[i][j] = mean(ll); 
        stds[i][j] = std(ll); 
        distributions.push(new NormalDistribution(means[i][j], stds[i][j]));
    }
}


///// Building input to the zokrates 
data = multiply(transpose(transpose(coll.map(x => x.slice(0, idx[1])).slice(0,4))), 1000);
console.log(data[0].length);

append  = Array(NumberOfFeatures - 1).fill().map( () => Array(coll[0].length - idx[1] + 1 ).fill(0));
dataAppended = data.map((x, index) =>  {
    return [data[index]+ append[index] + floor(multiply(means[index][0] , 1000 * (coll[0].length - idx[1] -2)))]
});

console.log(dataAppended, 120 - data[0].length);
console.log(means, stds);
probs = Array(res.test.length).fill().map(() => Array(target.length).fill(0));
predLabels = Array(res.test.length).fill(0); 
prob = Array(4).fill().map(() => Array(target.length).fill(1));
labelStr = transpose(res.test)[4];

let tp = 0 ;
labels = []; 
for (let Id = 0; Id < res.test.length; Id ++) {
    prob = Array(target.length).fill(1);
    for (let i = 0; i < 4 ; i++) {
        for (let j=0; j< target.length; j++) {
            tempProp = distributions[3*i + j+1].pdf(res.test[Id][i]);
            prob[j] = prob[j] * tempProp;
        } 

    }
    probs[Id] = prob;
    predLabels[Id] = argmax(prob);
    if (labelStr[Id] == target[0]){
        labels.push(0);
    }   
    else if (labelStr[Id] == target[1]){
        labels.push(1);
    }  
    else {
        labels.push(2);
    }  
    if (labels[Id] == predLabels[Id]) {
        tp += 1;
    }
}
console.log(predLabels); 
console.log(labels);
console.log("accuracy is ", tp/labels.length);