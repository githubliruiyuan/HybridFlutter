const readline = require('readline');

module.exports = async function () {
    let promise = new Promise((resolve, reject) => {
        const rl = readline.createInterface({  
            input: process.stdin,  
            output: process.stdout  
        });  
        rl.on('line', function (input) {
            resolve([input, rl]);
        });  
          
        rl.on('close', function() {  
              
        });
    });
    return  promise;
}