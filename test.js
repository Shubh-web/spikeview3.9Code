var _ = require('underscore');

var name = 'vivek  kumar   yadav';
var nam = name.split(' ');
_.forEach(nam, function(ob){
    console.log(ob, ob.length);
})
