const { transpose, mean, std, indexDependencies, i } = require('mathjs');
const {readCSV, trainTestSplit} = require('./dataHandler'); 
const gaussian = require("normal-distribution");
const  NormalDistribution  = require('gaussian');
const argmax = require('compute-argmax');


NumberOfFeatures = 5; 
data = readCSV('iris', NumberOfFeatures); 
res = trainTestSplit(data, 0.8); 


idx = []; 
target = ['Iris-virginica', 'Iris-versicolor', 'Iris-setosa']; 


coll = transpose(res.train);


means = Array(NumberOfFeatures - 1).fill().map(() => Array(target.length).fill(0));
stds = Array(NumberOfFeatures - 1 ).fill().map(() => Array(target.length).fill(0));
for (let i= 0; i < target.length; i++) { 
    idx.push(coll[4].indexOf(target[i]));
}
idx.push(coll[4].length); 
// sort string values in order of occurence 
idx = idx.sort();
for (let i = 0 ; i<target.length ; i++) { 
    target[i] = coll[4][idx[i]];
}
console.log(target);
distributions = [[]];
for (let i=0; i < coll.length -1 ; i++) {
    arr = coll[i]; 
    for (let j=0; j< target.length; j++) {
        ll = arr.slice(idx[j], idx[j+1]-1);
        means[i][j] = mean(ll); 
        stds[i][j] = std(ll); 
        distributions.push(new NormalDistribution(means[i][j], stds[i][j]));
    }
}

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