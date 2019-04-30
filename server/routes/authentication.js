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



router.post('/loginUser',(req,res)=>{
    let user=req.body;
    let sql="select * from customer where email='"+user.email+"' and password='"+user.password+"'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(!result){
                res.status(401).send("Invalid email");
            } else {
                if(result.length<1){
                    res.status(500).send("Invalid Password!!");
                } else {
                    let payload ={subject:result[0].customer_id};
                    let token = jwt.sign(payload,'MysupersecreteKey');
                    res.status(200).send({token});
                }
            }
        }
    })
})

router.post('/registerUser',(req,res)=>{
    let user=req.body;
    let sql="select * from customer where email='"+user.email+"'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result.length>0){
                res.status(500).send("Email is alreay signed up");
            } else {
                sql="select * from customer where mob_phone="+user.mobile;
                con.query(sql,(err,result)=>{
                    if(err){
                        console.log(err);
                    } else {
                        if(result.length>0){
                            res.status(500).send("Mobile is already signed up");
                        } else {
                            sql="insert into customer(name,email,password,mob_phone) values('"+user.name+"','"+user.email+"','"+user.password+"',"+user.mobile+")"
                            con.query(sql,(err,result)=>{
                                if(err){
                                    console.log(err);
                                } else {
                                    sql="select * from customer where name='"+user.name+"' and email='"+user.email+"' and password='"+user.password+"' and mob_phone="+user.mobile;
                                    con.query(sql,(err,result)=>{
                                        if(err){
                                            console.log(err);
                                        } else {
                                            sql="update customer set cart_id="+result[0].customer_id+" where customer_id="+result[0].customer_id
                                            con.query(sql,(err,result)=>{
                                                if(err){
                                                    console.log(err);
                                                }
                                            })
                                            let payload={subject:result[0].customer_id}
                                            let jwt_token=jwt.sign(payload,'MysupersecreteKey')
                                            let jwt_obj={'token':jwt_token}
                                            res.status(200).send(jwt_obj);
                                        }
                                    })
                                    
                                }
                            })
                        }
                    }
                })
            }
            
        }
    })
})

router.get('/getUserDetail',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select * from customer where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})




module.exports=router