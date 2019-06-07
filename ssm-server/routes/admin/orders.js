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

router.get('/getPendingOrder/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select o.*,p.name,p.thumbnail from order_detail o,product_variants p where o.product_variant_id=p.variant_id and status_id=0 and o.user_id="+payload.subject+" limit "+req.params.up+","+limit;
    con.query(sql,(err,orders)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(orders);
        }
    })
});

router.get('/countPendingOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(*) as pendingOrder from order_detail where status_id=0 and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    })
});

router.post('/confirmOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let item_id=req.body;
    let sql="update order_detail set status_id=1 where item_id="+item_id.item_id+ " and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json({success:true,message:"Order is confirmed"});
        }
    });
});

router.get('/getConfirmedOrder/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select o.*,p.name,p.thumbnail from order_detail o,product_variants p where o.product_variant_id=p.variant_id and status_id=1 and o.user_id="+payload.subject+" limit "+req.params.up+","+limit;
    con.query(sql,(err,orders)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(orders);
        }
    })
});

router.get('/countConfirmedOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(*) as confirmedOrder from order_detail where status_id=1 and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    })
});

router.post('/dispatchOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let item_id=req.body;
    let sql="update order_detail set status_id=2 where item_id="+item_id.item_id+ " and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json({success:true,message:"Order is confirmed"});
        }
    });
});

router.get('/getDispatchedOrder/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select o.*,p.name,p.thumbnail from order_detail o,product_variants p where o.product_variant_id=p.variant_id and status_id=2 and o.user_id="+payload.subject+" limit "+req.params.up+","+limit;
    con.query(sql,(err,orders)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(orders);
        }
    })
});

router.get('/countDispatchedOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(*) as dispatchedOrder from order_detail where status_id=2 and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    })
});

router.post('/deliverOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let item_id=req.body;
    let sql="update order_detail set status_id=3 where item_id="+item_id.item_id+ " and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json({success:true,message:"Order is confirmed"});
        }
    });
});

router.get('/getDeliveredOrder/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select o.*,p.name,p.thumbnail from order_detail o,product_variants p where o.product_variant_id=p.variant_id and status_id=3 and o.user_id="+payload.subject+" limit "+req.params.up+","+limit;
    con.query(sql,(err,orders)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(orders);
        }
    })
});

router.get('/countDeliveredOrder',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(*) as deliveredOrder from order_detail where status_id=3 and user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    })
});

module.exports=router;