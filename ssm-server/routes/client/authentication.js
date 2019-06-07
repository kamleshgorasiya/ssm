const express=require('express')
const jwt=require('jsonwebtoken')
const bcrypt=require('bcrypt');
const nodemailer=require('nodemailer');
const router=express.Router();

const con=require('../../database_connection');

var transporter = nodemailer.createTransport({
    host:'smtp.gmail.com',
    port:587,
    secure:false,
    requireTLS: true,
    auth: {
      user: 'pmdhankecha.18@gmail.com',
      pass: '260519991999'
    }
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



router.post('/loginUser',(req,res)=>{
    let user=req.body;
    let sql="select * from customer where email='"+user.email+"'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(!result){
                res.status(401).send({success:false,message:"Invalid email"});
            } else {
              
                if(result.length<1){
                    res.status(500).send({success:false,message:"Invalid password"});
                } else {
                    var passwordChecker=new Promise((resolve,reject)=>{
                        bcrypt.compare(user.password,result[0].password,(err,response)=>{
                            resolve(response);
                        })
                    })
                    passwordChecker.then(function(val){
                        if(val){
                            let payload ={subject:result[0].customer_id};
                            let token = jwt.sign(payload,'MysupersecreteKey');
                            res.status(200).send({success:true,message:"Logged in successfully",token:token});
                        } else{
                            res.status(500).send({success:false,message:"Invalid password"});
                        }
                    });
                }
            }
        }
    });
});

router.post('/registerUser',(req,res)=>{
    let user=req.body;
    if(user.mobile.length!=10){
        res.status(500).send("Mobile number is not valid");
    } else {
        let sql="select * from customer where email='"+user.email+"'";
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                if(result.length>0){
                    res.status(500).send({success:false,message:"Email is alreay signed up"});
                } else {
                    sql="select * from customer where mob_phone="+user.mobile;
                    con.query(sql,(err,result)=>{
                        if(err){
                            console.log(err);
                        } else {
                            if(result.length>0){
                                res.status(500).send({success:false,message:"Mobile is already signed up"});
                            } else {
                                let password;
                                var passwordGenerate=new Promise((resolve,reject)=>{
                                    bcrypt.hash(user.password,10,function(err,hash){
                                    password=hash;
                                    resolve(password);
                                    });
                                });
                                passwordGenerate.then(function(val){
                                sql="insert into customer(name,email,password,mob_phone) values('"+user.name+"','"+user.email+"','"+password+"',"+user.mobile+")"
                                con.query(sql,(err,result)=>{
                                    if(err){
                                        console.log(err);
                                    } else {
    
                                        sql="select * from customer where email='"+user.email+"'";
                                        
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
                                                let jwt_obj={success:true,message:"User registered successfully",'token':jwt_token}
                                                res.status(200).send(jwt_obj);
                                            }
                                        })
                                        
                                    }
                                })
                                }) 
                            }
                        }
                    })
                }
                
            }
        })
    }
    
})

router.get('/getUserDetail',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select name from customer where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    });
});

router.post('/forgetPassword',(req,res)=>{
    let data=req.body;
    let sql="select * from customer where email='"+data.email+"'" ;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            if(result.length>0){
                let otp=Math.floor(Math.random()*1000000);
                otp=(otp*(result[0].customer_id.toString().length*10))+result[0].customer_id;
                let email=user[0].email;
                var mailOptions = {
                    from: 'youremail@gmail.com',
                    to: email,
                    subject: 'Order Confirmation',
                    html:'<h1>Order Recieved</h1><br>Order No. '
                  };
                transporter.sendMail(mailOptions,(err,info)=>{
                    if(err){
                        console.log(err);
                    } else {
                        
                    }
                });
            }
        }
    });
});

module.exports=router