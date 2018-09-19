
 logdata = load 'logs.tsv';
logdat2 = foreach logdata generate (chararray) $12 as url,(chararray) $13 as id;
logs = foreach logdat2 generate url,SUBSTRING(id,1,37) as id:chararray;



urldata = load 'urlmap.tsv';
urls = foreach urldata generate (chararray) $0 as url,(chararray) $1 as category;
logjoinurl = JOIN logs by url LEFT OUTER,urls by url;
logsnurl = foreach logjoinurl generate logs::url as url,logs::id as id,urls::category as category;
logurluser = JOIN logsnurl by id LEFT OUTER,user by id;
STORE logurluser into 'logurluser';
filtered = filter logurluser by agegrp is not null;
youths = FILTER filtered by agegrp =='youth';
adults = FILTER filtered by agegrp =='adult';
seniors = FILTER filtered by agegrp =='senior';

justycat = foreach youths generate $0;
grouped = GROUP justycat by $0;
ycount = foreach grouped generate group as category,COUNT(justycat);

justacat = foreach adults generate $0;
grouped = GROUP justacat by $0;
acount = foreach grouped generate group as category,COUNT(justacat);

justscat = foreach seniors generate $0;
grouped = GROUP justscat by $0;
scount = foreach grouped generate group as category,COUNT(justscat);

yns = JOIN ycount by category,acount by category;
ynsfilter = foreach yns generate ycount::category as category,ycount::total as youngs,acount::total as adults;
allcount = JOIN ynsfilter by category,scount by category;
final = foreach allcount generate ynsfilter::category as category,ysnfilter::youngs as youngs,ynsfilter::adults as adults, scount::total as seniors;
describe final;
STORE final into 'categorybyagegroup';

#Give output based on categories 
