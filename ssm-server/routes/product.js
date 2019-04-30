const express=require('express')
const jwt=require('jsonwebtoken')
const router=express.Router()

const mysql=require('mysql');

const con=mysql.createConnection({
    host:"localhost",
    user:"root",
    password:"",
    database:"ssm"
});

function verifyToken(req,res,next){
    if(!req.headers.authorization){
        return res.status(401).send('Unauthorized Request1');
    }
    let token=req.headers.authorization.split(' ')[1];
    if(token==="null"){
        return res.status(401).send("Unauthorized Request2");
    }
    let payload=jwt.verify(token,'MysupersecreteKey');
   
    if(!payload){
        return res.status(401).send("Unauthorized Request3");
    }
    req.userId=payload.subject;
    //console.log(req.userId);
    next(); 
}

router.post('/allProducts',(req,res)=>{
    let limits=req.body;
    let sql="select * from product limit "+limits.up+","+limits.limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.post('/productById',(req,res)=>{
    let id=req.body;
    let sql="select * from product where product_id="+id.product_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/countProduct',(req,res)=>{
    let sql="select count(*) as countp from product";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/category',(req,res)=>{
    let sql="select * from category";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.post('/productByCategory',(req,res)=>{
    let category=req.body;
    let sql="select p.* from product p,product_category c where c.category_id="+category.categoryId+" and c.product_id=p.product_id limit "+category.up+","+category.limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.post('/countByCategory',(req,res)=>{
    let category=req.body;
    let sql="select count(product_id) as countp from product_category where category_id="+category.categoryId ;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/department',(req,res)=>{
    let sql="select * from department";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.post('/getProductByName',(req,res)=>{
    let product=req.body;
    let sql="select * from product where name like '%"+product.name+"%'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

module.exports=router