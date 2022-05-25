var undefinish = require("@hugoalh/undefinish");
var input = {
	displayName: null,
	age: 8
};
console.log(input.username ?? input.name ?? input.displayName ?? "owl");
console.log(undefinish(input.username, input.name, input.displayName, "owl"));
