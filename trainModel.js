const { transpose, mean, std, indexDependencies, i } = require('mathjs');
const {readCSV, trainTestSplit} = require('./dataHandler'); 
const gaussian = require("normal-distribution");
const { default: NormalDistribution } = require('normal-distribution');

NumberOfFeatures = 5; 
data = readCSV('iris', NumberOfFeatures); 
res = trainTestSplit(data, 0.8); 


idx = []; 
target = ['Iris-virginica', 'Iris-versicolor', 'Iris-setosa']; 


// coll = res.train[0].map(function (_, c) { return res.train.map(function (r) { return r[c]; }); });
// console.log(coll);
coll = transpose(res.train);


means = Array(NumberOfFeatures - 1).fill().map(() => Array(target.length).fill(0));
stds = Array(NumberOfFeatures - 1 ).fill().map(() => Array(target.length).fill(0));
for (let i= 0; i < target.length; i++) { 
    idx.push(coll[4].indexOf(target[i]));
}
idx.push(coll[4].length); 
idx = idx.sort();
distributions = [[NormalDistribution]];
for (let i=0; i < coll.length -1 ; i++) {
    arr = coll[i]; 
    for (let j=0; j< target.length; j++) {
        ll = arr.slice(idx[j], idx[j+1]-1);
        means[i][j] = mean(ll); 
        stds[i][j] = std(ll); 
        distributions.push(new NormalDistribution(means[i][j], stds[i][j]));
    }
}

console.log(means);

probs = Array(NumberOfFeatures - 1).fill().map(() => Array(target.length).fill(0));
console.log(res.test[1][2]);
console.log(distributions[11].pdf(res.test[1][2]));
for (let i=0; i < 5 ; i++) {
    for (let j=0; j< target.length; j++) {
        val = i*j ;
        tempDist = distributions[val];
        probs[i][j] = tempDist.pdf(res.test[1][i]);
    }
}


console.log(probs);