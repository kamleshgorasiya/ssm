const express=require('express')
const jwt=require('jsonwebtoken')
const bcrypt=require('bcrypt');
const router=express.Router();
const limit=10;

const con=require('../../database_connection');

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

router.get('/getAllAttributes/:up',verifyToken,(req,res)=>{
    let up=req.params.up;
    let sql="select * from attribute limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result){
                res.status(200).json(result);
            } else {
                res.status(404).send("There is no more Attributes");
            }
        }
    });
});

router.get('/countAttributes',verifyToken,(req,res)=>{
    let sql="select count(*) as countAttribute from attribute";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});

router.post('/addAttribute',verifyToken,(req,res)=>{
    let attribute=req.body;
    if(attribute.name.length<1){
        res.status(500).send("Data is not Proper. Enter name of more than 2 Characters");
    } else{
        
        let sql='insert into attribute(name) values("'+attribute.name+'")';
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                res.status(200).send({message:"Attribute's value added successfully"});
            }
        })
        
    }
 });

 router.post('/updateAttributeValue',verifyToken,(req,res)=>{
    let attribute=req.body;
    if(attribute.name.length<1){
        res.status(500).send("Data is not Proper. Value cannot be null");
    } else{
        
        let sql='update attribute set name="'+attribute.name+'" where attribute_id='+attribute.attribute_id;
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                res.status(200).send({message:"Attribute Value updated successfully"});
            }
        });
        
    }
});

router.post('/deleteCategory',verifyToken,(req,res)=>{
    let category=req.body;
    let sql="  count(o.item_id) as totalorder from order_detail o,product_variants pv,product_category pc where pc.category_id="+ category.category_id+" and pc.product_id=pv.product_id and pv.variant_id=o.product_variant_id";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result[0].totalorder<1){
                sql="update category set isDelete=1  where category_id="+category.category_id;
                con.query(sql,(err,result)=>{
                    if(err){
                        console.log(err);
                    } else {
                        res.status(200).send({"message":"Category is deleted successfully"});
                    }
                })
            } else {
                res.status(200).send({"message":"Category is aleready in use"});
            }
        }
    });
});

router.get('/searchAttributeValue/:key',verifyToken,(req,res)=>{
    let key=req.params.key;
    if(key!=""){
        let sql="select * from attribute where name like '%"+key+"%'";
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                res.status(200).json(result);
            }
        });
    }
});

module.exports=router;