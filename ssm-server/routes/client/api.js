const express=require('express')
const jwt=require('jsonwebtoken')
const router=express.Router()
const con=require('../../database_connection');

router.get('/', (req,res) => {
    res.send("Data From API");
});

function verifyToken(req,res,next){
    if(!req.headers.authorization){
        return res.status(401).send("Unauthorized Request! Header Not Found");
    }
    let token=req.headers.authorization.split(' ')[1];
    if(token==="null"){
        return res.status(401).send("Unauthorized Request! Token Not Found");
    }
    let payload=jwt.verify(token,'MysupersecreteKey');
   
    if(!payload){
        return res.status(401).send("Unauthorized Request! Token is not Correct");
    }
    req.userId=payload.subject;
    next(); 
}

router.get('/shippingRegion',(req,res)=>{
    let sql="select * from shipping_region";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/shippingOptions',(req,res)=>{
    let sql="select * from shipping";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.post('/addAddress',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let address=req.body;
    let sql="update customer set address_1='"+address.address1+"', address_2='"+address.address2+"', city='"+address.city+"', region='"+address.region+"', postal_code='"+address.postalCode+"', country='"+address.country+"', shipping_region_id="+address.shipping_region_id+" where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.status(200).send({"message":"Address is added"});
        }
    })
})

router.get('/getAddress',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select address_1,address_2,city,region,postal_code,country,shipping_region_id from customer where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})


module.exports=router