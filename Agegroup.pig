urlmap = load 'urltest.tsv';

urldata = foreach urlmap generate (chararray) $0 as url,(chararray) $1 as category;
urlmovie = FILTER urldata by category == 'movies';

rawlogs = load 'logtest.tsv';

logdata = foreach rawlogs generate (chararray) $1 as date,(chararray) $7 as ip,
(chararray) $12 as url,(chararray) $13 as id,
(chararray) $49 as region,(chararray) $50 as country;

log_joinurl = JOIN logdata by url LEFT OUTER,urlmovie by url;
filteredlogs = FILTER log_joinurl by $7 is not null;
fullfilter = foreach filteredlogs generate date,ip,logdata::url as url,SUBSTRING(id,1,37) as id,region,country,category;
---------------
#Filter Records

regusers = load 'regusers.tsv';


userdata = foreach regusers generate (chararray) $0 as id,(chararray) $1 as dob,(chararray) $2 as gender;


records = JOIN fullfilter by id LEFT OUTER,userdata by id;
userdata = load 'users.tsv';
usercol = foreach userdata generate (chararray) $0 as id,(chararray) $1 as bday,(chararray) $2 as gender;
usertodate = foreach usercol generate id,bday,ToDate(bday,'dd-MMM-yy') as dob:datetime,gender;
withnow = foreach usertodate generate id,bday,dob,CurrentTime() as now:datetime,gender;
yeardiff = foreach withnow generate id,bday,YearsBetween(now,dob) as age:int,gender;
idage = foreach yeardiff generate id,age,gender;
 
withage = foreach withnow generate id,bday,YearsBetween(now,dob) as age:int,gender;
filternow = FILTER withnow by $1 is not null;
withage2 = foreach filternow generate id,bday,YearsBetween(now,dob) as age:int,gender;
describe withage2;
agegroup = foreach withage2 generate id,(age<30?'youth':(age>50?'senior':'adult')) as agegrp:chararray,gender;
STOrE agegroup into 'agegroup';
user = foreach agegroup generate id,agegrp,gender;

#differentiate based in age groups
